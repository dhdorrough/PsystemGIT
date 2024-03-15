unit Ped_defs;
{ This item is the property of SofTech Microsystems, Inc., and it   }
{ may be used, copied or distributed only as permitted in a written }
{ license from that company.                                        }

interface

uses
  UCSDGlob;
     
const 
  
      
      {The following constants define the size of a block in various
       units.  These constants should really be declared with the
       FBLKSIZE system constant, but for now they are declared locally
       here.}
       
      bytes_per_word = 2;
                                {Number of bytes in a word.}
                                
      words_per_block = 256;
                                {Number of words in a block; equal to
                                 FBLKSIZE DIV BYTES_PER_WORD.}
                                 
    
       
      {The following constants constitute part of the interface to the
       PED_BUILD routine.}
       
      
      min_ped_buffer_index = 0;
                                {Minimum index into a PED_BUFFER.
                                 Note that the code contains 
                                 dependencies on this value always
                                 being zero (for increased efficiency).}
    
      ped_max_file_name = 255;
                                {Maximum length of a file name.}

                                 
      {These two constants place restrictions on the number of separate
       library files and operating system segments which can be referenced
       by a PED.  These constants may be increased and the affected 
       system units re-compiled at the cost of more stack space being
       required during the process of reconstructing the execution
       environment from a PED.}
       
      max_library_file_refs = 50;
                                {Maximum number of separate library
                                 code files which may be referred to
                                 by a PED.}

      max_system_seg_refs = 50;
                                {Maximum number of operating system
                                 segments that can be referenced by
                                 a PED.}
                                 

      ped_unused_words = 5;
                                {Number of unused words at end of
                                 ped_header record.}

      chars_per_seg_name = 8;   {Number of characters in a segment}

type
      
      {The following types define the structures which are generated
       within a PED.}

      TPed_HeaderPtr = ^TPed_Header;

      TPed_header =              {PED Header Record.}
          record
            ped_byte_sex: integer;
                                {PED Byte sex indicator.}
             
            ped_format_level: integer;
                                {PED structures version indicator.}
                                 
            ped_library_count: integer;
                                {Number of library
                                 file descriptors.}
             
            ped_principal_segment_count: integer;
                                {Number of principal
                                 segments described.}
             
            ped_subsidiary_segment_count: integer;
                                {Number of 
                                 subsidiary segments
                                 described.}
             
            ped_total_evec_words: integer;
                                {Size of EVEC 
                                 templates.}
             
            ped_last_system_segment: integer;
                                {Last global segment
                                 number assigned to
                                 identify system
                                 units.}
                                 
            ped_start_unit: integer;
                                {Global segment
                                 number of
                                 principal segment
                                 where execution
                                 should begin.}
           
            ped_uses_realops_unit: boolean;
                                {TRUE if REALOPS
                                 unit required.}
                                 
            {The following portion of the ped_header varies
             depending on the format level. The structure will
             be defined in terms of format level 3. Minor 
             adjustments to ped_header size will have to be made
             to run programs with formats 1 and 2. Format 1 is
             produced by systems before IV.2. Format 2 and 3 are
             produced by IV.2 and above.}
            
            
            { FORMAT 1 HEADER ends with
            ped_expansion_area:
                 array[1..ped_unused_words] of 0..0;
            
            }
            
            { FORMAT 2 HEADER ends with
            ped_level_2: array[0..1] of integer;
            ped_expansion_area:
                 array[1..ped_unused_words-2] of 0..0;
            
            }
            
            { FORMAT 3 HEADER ends with}
            ped_level_3: array[0..5] of integer;
            ped_expansion_area:
                 array[1..ped_unused_words] of 0..0;
                                {Reserved for
                                 future use.}
          end;


   segment_name = packed array[1..chars_per_seg_name] of char; {Universal segment name structure.}
   
      ped_pseudo_sib =          {PED Pseudo SIB Structure.}
        record
          ps_seg_name: segment_name;
                                {Name of segment.}
          
          ps_seg_leng: integer;
                                {Length of segment.}
                        
          ps_seg_addr: integer;
                                {Relative block
                                 address of segment
                                 in library file.}
                         
          ps_seg_data_size: integer;
                                {Size of segment
                                 data area.}
                         
          ps_seg_lib_num: integer;
                                {Index into sequence
                                 of library code 
                                 file descriptors.}
                         
          ps_seg_attributes:
               packed
               record
                 dummy: word; // Delphi does not pack to the bit level
(*
                 ps_relocatable: boolean;
                                {Relocatable
                                 indicator from
                                 segment
                                 dictionary.}

                 ps_mach_type: m_types;
                                {Type of code in
                                 segment.}
                 ps_filler: 0..2047;
                                {11 bits of filler to
                                 round out to one word.}
*)
              end;
        end;


      ped_evec_ptr = ^ped_evec;
      ped_evec =                {EVEC structure used within a PED.
                                 This structure is the same as the
                                 standard EVEC except that the MAP
                                 array is an array of integers instead
                                 of an array of EREC pointers.}
          record
            vect_length: integer;
                                {Number of entries in MAP array.}
                                
            map: array[1..1] of integer;
                                {The table of global segment numbers.}
          end;
          
      
      ped_untyped_file = file;
                                {Defines the type of FIB which is generated
                                 as part of the working storage section of
                                 a transient PED.}
  
      
      {The following types define the structure of a PED descriptor
       and other types which are used in the interface to PED_BUILD.}
       
       
                                 
      ped_kinds =
                                {Types of program
                                 environment descriptors.}

          (ped_transient,
                                {Transient type of environment
                                 descriptor which is used by the
                                 operating system to create the
                                 environment for the program.  This
                                 form of PED may not be inserted into
                                 a host program code file since it
                                 is not configuration independent.}

           ped_permanent
                                {Type of pre-associated environment 
                                 which can be stored in the code
                                 file of the host program.}
                                  
          );


                                 
      ped_dest_kinds =          {Kinds of "destinations" for the PED
                                 constructed by PED_BUILD.}
          (ped_to_mem,
                                {PED is generated into a single memory
                                 buffer.  For this type of destination,
                                 the size of the buffer determines the
                                 maximum size of the PED which can be
                                 constructed by PED_BUILD.}
           
           ped_to_file
                                {PED buffer is written to a file when
                                 buffer becomes full or when the PED
                                 construction is complete.  Thus the
                                 size of the buffer does not limit the
                                 size of the PED which can be built by
                                 PED_BUILD.}
          );
          
      
      ped_mem_ptr = ^ped_mem_array;
      ped_mem_array = window;
                                {Type describing the buffer into which
                                 PED_BUILD returns the PED.  The actual
                                 size of one of these buffers is passed
                                 as a field of the PED_DESCRIPTOR record.
                                 This structure is made equivalent to 
                                 the WINDOW structure used by FBLOCKIO
                                 in order that the calling of FBLOCKIO
                                 would be simple.}
      
      ped_mem_range = 0 .. maxint;
                                {Conceptually, the range of indexes
                                 into a PED_MEM_ARRAY.}


      ped_descriptor =          {Structure passed to PED_BUILD which
                                 describes the type and destination 
                                 for the PED which is to be constructed.}
          record
            ped_kind: ped_kinds;
                                {The kind of PED to construct.}
            
            ped_bufp: ped_mem_ptr;
                                {Buffer into which the PED is to 
                                 be constructed.  The size of this
                                 buffer is indicated by the 
                                 PED_BUF_MAX_INX indicator below.}
            
            ped_buf_inx: ped_mem_range;
                                {Index into the buffer of next available
                                 byte in buffer.}
                                 
            ped_buf_max_inx: ped_mem_range;
                                {Maximum index into the buffer.  The size
                                 of the buffer must be appropriate for the
                                 requested destination for the PED.  If the
                                 PED is to be written to a code file by
                                 PED_BUILD, this buffer must be at least
                                 one block in size; otherwise the buffer
                                 must be large enough to contain the PED
                                 all at once.}
            
            case ped_destination: ped_dest_kinds of
                                {Determines the destination for the final
                                 constructed PED.  Note that the setting
                                 of PED_KIND is independent of the type of
                                 destination for the PED.}
              ped_to_mem: ();
              ped_to_file:
                  (ped_fibp: fib_p;
                                {The file to which the PED is to be written.}
                   
                   ped_next_blk: integer
                                {Block number of next available block in the
                                 file to which the PED is being written.}
                  );
          end;
          

      ped_fname_ptr = ^ped_file_name;
      ped_file_name = string[ped_max_file_name];
                                {String type used to return the names
                                 of missing units and library code file
                                 titles.  This type is large enough for
                                 an AFS file pathname.}
                                 
      
      ped_result =              {Result codes returned by PED_BUILD.}
           
           (ped_no_error,
                                {Result indicating
                                 successful
                                 operation.}
                         
            ped_lib_error,
                                {Indicates I/O error either
                                 on open or read of a
                                 library code file.}
                        
            ped_lib_output_error,
                                {Indicates I/O error when
                                 creating a copy of an updated
                                 library code file.}
                                 
            ped_chksum_error,
                                {I/O error occurred when 
                                 attempting to insert new
                                 checksum into a referenced
                                 library code file.}
                                 
            ped_output_error,
                                {Indicates I/O error writing
                                 PED to disk file.}
            
            ped_unit_error,
                                {Indicates failure to locate
                                 a referenced unit.}
                         
            ped_bad_library_list_error,
                                {Library file list text file
                                 is not a textfile.}
                                 
            ped_lib_list_error,
                                {Indicates I/O error reading
                                 library file list text file.}
                                 
            ped_duplicate_unit_error,
                                {A unit name conflicts with
                                 a system unit name, or the
                                 system contains more than 
                                 one unit with the same name.}
                                 
            ped_lib_count_error,
                                {Number of referenced library code
                                 files exceeds max_library_file_refs.}
                                 
            ped_sys_ref_count_error,
                                {Number of separate system segment
                                 references exceeds max_system_seg_refs.}
                                 
            ped_no_program_error,
                                {Input file is not a host
                                 program, or the operating system
                                 host unit is missing from an
                                 operating system host code file.}
                         
            ped_no_boot_seg_error,
                                {System host code file does not
                                 contain the required boot segment.}
                                 
            ped_must_be_linked_error,
                                {Program environment references
                                 an segment which contains 
                                 unresolved references to 
                                 assembly language routines.
                                 Thus the program must be 
                                 linked by the Linker before an
                                 environment can be constructed.}
                         
            ped_obsolete_segment_error,
                                {Program contains a reference to
                                 a segment which was not compiled
                                 with a Version IV compiler.}
                                 
            ped_not_enough_mem_error,
                                {Not enough memory to build
                                 required temporary data 
                                 structures during environment
                                 construction process.}
                                 
            ped_buf_overflow,
                                {The buffer into which the PED
                                 is being generated in not large
                                 enough to describe the environment
                                 for the program.}
                         
            ped_too_many_users,
                                {CUP mechanism has detected too
                                 many concurrent users of this
                                 program.}
                                
            ped_cup_full
                                {CUP DEVICE is already full of 
                                 software ids}
            
            );
       
implementation  
  
begin
end.
