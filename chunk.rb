#
# Chunk
# 
# Reads a large file in as chunks for easier parsing.
# 
# The chunks returned are whole <@@options['element']/>s found within file.
# 
# Each call to read() returns the whole element including start and end tags.
# 
# Tested with a 1.8MB file, extracted 500 elements in 0.09s
# (with no work done, just extracting the elements)
# 
# Usage:
# <code>
#   # initialize the object
#   file = Chunk.new('chunk-test.xml', { 'element' => 'Chunk' })
#   
#   # loop through the file until all lines are read
#   while xml = file->read()
#     # do whatever you want with the string
#     puts xml
#   end
# </code>
# 
class Chunk
  # options
  #
  # @var hash Contains all major options
  # 
  @@options = {
    'path' => './',
    'element' => '',
    'chunkSize' => 512
  }
  
  # file
  #
  # @var string The filename being read
  # 
  @@file = ''
  
  # pointer
  #
  # @var integer The current position the file is being read from
  # 
  @@pointer = 0
  
  # handle
  #
  # @var resource The File.open() resource
  # 
  @@handle = nil
  
  # reading
  #
  # @var boolean Whether the script is currently reading the file
  # 
  @@reading = false
  
  # readBuffer
  # 
  # @var string Used to make sure start tags aren't missed
  # 
  @@readBuffer = ''
  
  # initialize
  # 
  # Builds the Chunk object
  #
  # @param string $file The filename to work with
  # @param hash $options The options with which to parse the file
  # 
  def initialize(file, options = {})
    # merge the options together
    @@options.merge!(options.kind_of?(Hash) ? options : {})
    
    # check that the path ends with a /
    if @@options['path'][-1, 1] != '/'
      @@options['path'] += '/'
    end
    
    # normalize the filename
    file = File.basename(file)
    
    # make sure chunkSize is an int
    @@options['chunkSize'] = @@options['chunkSize'].to_i()
    
    # check it's valid
    unless @@options['chunkSize'] >= 64
      @@options['chunkSize'] = 512
    end
    
    # set the filename
    @@file = File.expand_path(@@options['path'] + file)
    
    # check the file exists
    unless File.exists?(@@file)
      raise Exception.new('Cannot load file: ' + @@file)
    end
    
    # open the file
    @@handle = File.new(@@file, 'r')
    
    # check the file opened successfully
    unless @@handle
      raise Exception.new('Error opening file for reading')
    end
    
    # add a __destruct style method
    ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
  end
  
  # finalize
  # 
  # Cleans up
  #
  # @return void
  # 
  def Chunk.finalize(id)
    @@handle.close()
  end
  
  # read
  # 
  # Reads the first available occurence of the XML element @@options['element']
  #
  # @return string The XML string from @@file
  # 
  def read()
    # check we have an element specified
    if !@@options['element'].nil? and @@options['element'].strip().length() > 0
      # trim it
      element = @@options['element'].strip()
      
    else
      element = nil
    end
    
    # initialize the buffer
    buffer = ''
    
    # if the element is empty
    if element.nil?
      # let the script know we're reading
      @@reading = true
      
      # read in the whole doc, cos we don't know what's wanted
      while @@reading
        buffer += @@handle.read(@@options['chunkSize'])
        
        @@reading = !@@handle.eof()
      end
      
      # return it all
      return buffer
      
    # we must be looking for a specific element
    else
      # set up the strings to find
      open = '<' + element + '>'
      close = '</' + element + '>'
      
      # let the script know we're reading
      @@reading = true
      
      # reset the global buffer
      @@readBuffer = ''
      
      # this is used to ensure all data is read, and to make sure we don't send the start data again by mistake
      store = false
      
      # seek to the position we need in the file
      @@handle.seek(@@pointer)
      
      # start reading
      while @@reading and !@@handle.eof()
        # store the chunk in a temporary variable
        tmp = @@handle.read(@@options['chunkSize'])
        
        # update the global buffer
        @@readBuffer += tmp
        
        # check for the open string
        checkOpen = tmp.index(open)
        
        # if it wasn't in the new buffer
        if checkOpen.nil? and !store
          # check the full buffer (in case it was only half in this buffer)
          checkOpen = @@readBuffer.index(open)
          
          # if it was in there
          unless checkOpen.nil?
            # set it to the remainder
            checkOpen = checkOpen % @@options['chunkSize']
          end
        end
        
        # check for the close string
        checkClose = tmp.index(close)
        
        # if it wasn't in the new buffer
        if checkClose.nil? and store
          # check the full buffer (in case it was only half in this buffer)
          checkClose = @@readBuffer.index(close)
          
          # if it was in there
          unless checkClose.nil?
            # set it to the remainder plus the length of the close string itself
            checkClose = (checkClose + close.length()) % @@options['chunkSize']
          end
          
        # if it was
        elsif !checkClose.nil?
          # add the length of the close string itself
          checkClose += close.length()
        end
        
        # if we've found the opening string and we're not already reading another element
        if !checkOpen.nil? and !store
          # if we're found the end element too
          if !checkClose.nil?
            # append the string only between the start and end element
            buffer += tmp[checkOpen, (checkClose - checkOpen)]
            
            # update the pointer
            @@pointer += checkClose
            
            # let the script know we're done
            @@reading = false
            
          else
            # append the data we know to be part of this element
            buffer += tmp[checkOpen..-1]
            
            # update the pointer
            @@pointer += @@options['chunkSize']
            
            # let the script know we're gonna be storing all the data until we find the close element
            store = true
          end
          
        # if we've found the closing element
        elsif !checkClose.nil?
          # update the buffer with the data upto and including the close tag
          buffer += tmp[0, checkClose]
          
          # update the pointer
          @@pointer += checkClose
          
          # let the script know we're done
          @@reading = false
          
        # if we've found the closing element, but half in the previous chunk
        elsif store
          # update the buffer
          buffer += tmp
          
          # and the pointer
          @@pointer += @@options['chunkSize']
        end
      end
    end
    
    # return the element (or the whole file if we're not looking for elements)
    return (buffer == '') ? false : buffer
  end
end
