.opt    nodotdirectives- ,
        scopemacros-

; Kernel Calls
; Populate the kernel.arg.* variables appropriately, and
; then JSR to one of the velctors below:

.namespace kernel

    .virtual    $ff00
    
        NextEvent   .fill   4   ; Copy the next event into user-space.
        ReadData    .fill   4   ; Copy primary bulk event data into user-space
        ReadExt     .fill   4   ; Copy secondary bolk event data into user-space
        Yield       .fill   4   ; Give unused time to the kernel.
        Putch       .fill   4   ; deprecated
        RunBlock    .fill   4   ; Chain to resident program by block ID.
        RunNamed    .fill   4   ; Chain to resident program by name.
                    .fill   4   ; reserved
        
        .namespace BlockDevice
            List        .fill   4   ; Returns a bit-set of available block-accessible devices.
            GetName     .fill   4   ; Gets the hardware level name of the given block device or media.
            GetSize     .fill   4   ; Get the number of raw sectors (48 bits) for the given device
            Read        .fill   4   ; Read a raw sector (48 bit LBA)
            Write       .fill   4   ; Write a raw sector (48 bit LBA)
            Format      .fill   4   ; Perform a low-level format if the media support it.
            Export      .fill   4   ; Update the FileSystem table with the partition table (if present).
        .endnamespace
        
        .namespace FileSystem
            List        .fill   4   ; Returns a bit-set of available logical devices.
            GetSize     .fill   4   ; Get the size of the partition or logical device in sectors.
            MkFS        .fill   4   ; Creates a new file-system on the logical device.
            CheckFS     .fill   4   ; Checks the file-system for errors and corrects them.
            Mount       .fill   4   ; Mark the file-system as available for File and Directory operations.
            Unmount     .fill   4   ; Mark the file-system as unavailable for File and Directory operations.
            ReadBlock   .fill   4   ; Read a partition-local raw sector on an unmounted device.
            WriteBlock  .fill   4   ; Write a partition-local raw sector on an unmounted device.
        .endnamespace
        
        .namespace File
            Open        .fill   4   ; Open the given file for read, create, or append.
            Read        .fill   4   ; Request bytes from a file opened for reading.
            Write       .fill   4   ; Write bytes to a file opened for create or append.
            Close       .fill   4   ; Close an open file.
            Rename      .fill   4   ; Rename a closed file.
            Delete      .fill   4   ; Delete a closed file.
            Seek        .fill   4   ; Seek to a specific position in a file.
        .endnamespace
        
        .namespace Directory
            Open        .fill   4   ; Open a directory for reading.
            Read        .fill   4   ; Read a directory entry; may also return VOLUME and FREE events.
            Close       .fill   4   ; Close a directory once finished reading.
            MkDir       .fill   4   ; Create a directory
            RmDir       .fill   4   ; Delete a directory
        .endnamespace
                    
                    .fill   4   ; call gate
        
        .namespace Net
            GetIP       .fill   4   ; Get the local IP address.
            SetIP       .fill   4   ; Set the local IP address.
            GetDNS      .fill   4   ; Get the configured DNS IP address.
            SetDNS      .fill   4   ; Set the configured DNS IP address.
            SendICMP    .fill   4
            Match       .fill   4
            
            .namespace UDP
                Init        .fill   4
                Send        .fill   4
                Recv        .fill   4
            .endnamespace
        
            .namespace TCP
                Open        .fill   4
                Accept      .fill   4
                Reject      .fill   4
                Send        .fill   4
                Recv        .fill   4
                Close       .fill   4
            .endnamespace
        .endnamespace
                    
        .namespace Display
            Reset       .fill   4   ; Re-init the display
            GetSize     .fill   4   ; Returns rows/cols in kernel args.
            DrawRow     .fill   4   ; Draw text/color buffers left-to-right
            DrawColumn  .fill   4   ; Draw text/color buffers top-to-bottom
        .endnamespace
        
        .namespace Clock
            GetTime     .fill   4
            SetTime     .fill   4
                        .fill   12  ; 65816 vectors
            SetTimer    .fill   4
        .endnamespace

    .endvirtual



    ; Kernel Call Arguments
    ; Populate the structure before JSRing to the associated vector.
    
    arg         = $00f0

    .namespace args
        .macro aevent_t
            dest       .word ? ; GetNextEvent copies event data here
            pending    .byte ? ; Negative count of pending events
        .endmacro
    
        ext         = $f8
        extlen      = $fa
        buf         = $fb
        buflen      = $fd
        ptr         = $fe
    
        .namespace run_type
            .virtual arg
                aevent_t()
                block_id   .byte ?
            .endvirtual
        .endnamespace
        
        .namespace recv_type
            .virtual arg
                aevent_t()
                buf        = kernel.args.buf
                buflen     = kernel.args.buflen
            .endvirtual
        .endnamespace
            
        .namespace fs_format_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                label      = kernel.args.buf
                label_len  = kernel.args.buflen
            .endvirtual
        .endnamespace
        
        .namespace fs_mkfs_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                label      = kernel.args.buf
                label_len  = kernel.args.buflen
            .endvirtual
        .endnamespace
        
        .namespace file_open_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                fname      = kernel.args.buf
                fname_len  = kernel.args.buflen
                mode       .byte ?
                        READ  = 0
                        WRITE = 1
                        END   = 2
            .endvirtual
        .endnamespace
        
        .namespace file_read_type
            .virtual arg
                aevent_t()
                stream     .byte ?
                buflen     .byte ?
            .endvirtual
        .endnamespace
        
        .namespace file_write_type
            .virtual arg
                aevent_t()
                stream     .byte ?
                buf        = kernel.args.buf
                buflen     = kernel.args.buflen
            .endvirtual
        .endnamespace
        
        .namespace file_seek_type
            .virtual arg
                aevent_t()
                stream     .byte ?
                position   .dword ?
            .endvirtual
        .endnamespace
        
        .namespace file_close_type
            .virtual arg
                aevent_t()
                stream     .byte ?
            .endvirtual
        .endnamespace
        
        .namespace file_rename_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                old        = kernel.args.buf
                old_len    = kernel.args.buflen
                new        = kernel.args.ext
                new_len    = kernel.args.extlen
            .endvirtual
        .endnamespace
        
        .namespace file_delete_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                fname      = kernel.args.buf
                fname_len  = kernel.args.buflen
                mode       .byte ?
                        READ  = 0
                        WRITE = 1
                        END   = 2
            .endvirtual
        .endnamespace
        
        .namespace directory_open_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                path       = kernel.args.buf
                path_len   = kernel.args.buflen
            .endvirtual
        .endnamespace
        
        .namespace directory_read_type
            .virtual arg
                aevent_t()
                stream     .byte ?
                buflen     .byte ?
            .endvirtual
        .endnamespace
        
        .namespace directory_close_type
            .virtual arg
                    aevent_t()
                stream     .byte ?
            .endvirtual
        .endnamespace
        
        .namespace directory_mkdir_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                path       = kernel.args.buf
                path_len   = kernel.args.buflen
            .endvirtual
        .endnamespace
        
        .namespace directory_rmdir_type
            .virtual arg
                aevent_t()
                drive      .byte ?
                cookie     .byte ?
                path       = kernel.args.buf
                path_len   = kernel.args.buflen
            .endvirtual
        .endnamespace
        
        .namespace display
            .virtual arg
                aevent_t()
                x          .byte ? ; coordinate or size
                y          .byte ? ; coordinate or size
                text       = kernel.args.buf ; text
                color      = kernel.args.ext ; color
                buflen     = kernel.args.buflen
            .endvirtual
        .endnamespace
        
        .namespace net_init_type
            .virtual arg
                aevent_t()
                socket     = kernel.args.buf
            .endvirtual
        .endnamespace
        
        .namespace net_send_type
            .virtual arg
                aevent_t()
                socket     = kernel.args.buf
                accepted   .byte ?
                buf        = kernel.args.ext
                buflen     = kernel.args.extlen
            .endvirtual
        .endnamespace
        
        .namespace net_recv_type
            .virtual arg
                aevent_t()
                socket     = kernel.args.buf
                accepted   .byte ?
                buf        = kernel.args.ext
                buflen     = kernel.args.extlen
            .endvirtual
        .endnamespace
        
        .namespace config_type
            .virtual arg
                aevent_t()
            .endvirtual
        .endnamespace
        
        .namespace timer
            .virtual arg
                aevent_t()
                units      .byte ?
                        FRAMES  = 0
                        SECONDS = 1
                        QUERY   = 128
                absolute   .byte ?
                cookie     .byte ?
            .endvirtual
        .endnamespace

    .endnamespace



    .namespace event
        type        = $00
        pending     = $f2
        .virtual 0
                        .word ?   ; Reserved
                        .word ?   ; Deprecated
            JOYSTICK    .word ?   ; Game Controller changes.
            DEVICE      .word ?   ; Device added/removed.
            
            .namespace key
                PRESSED     .word ?   ; Key pressed
                RELEASED    .word ?   ; Key released.
            .endnamespace
        
            .namespace mouse
                DELTA       .word ?   ; Regular mouse move and button state
                CLICKS      .word ?   ; Click counts
            .endnamespace
            
            .namespace block
                NAME        .word ?
                SIZE        .word ?
                DATA        .word ?   ; The read request has succeeded.
                WROTE       .word ?   ; The write request has completed.
                FORMATTED   .word ?   ; The low-level format has completed.
                ERROR       .word ?
            .endnamespace
            
            .namespace fs
                SIZE        .word ?
                CREATED     .word ?
                CHECKED     .word ?
                DATA        .word ?   ; The read request has succeeded.
                WROTE       .word ?   ; The write request has completed.
                ERROR       .word ?
            .endnamespace
            
            .namespace file
                NOT_FOUND   .word ?   ; The file file was not found.
                OPENED      .word ?   ; The file was successfully opened.
                DATA        .word ?   ; The read request has succeeded.
                WROTE       .word ?   ; The write request has completed.
                EOF         .word ?   ; All file data has been read.
                CLOSED      .word ?   ; The close request has completed.
                RENAMED     .word ?   ; The rename request has completed.
                DELETED     .word ?   ; The delete request has completed.
                ERROR       .word ?   ; An error occured; close the file if opened.
                SEEK        .word ?   ; The seek request has completed.
            .endnamespace
            
            .namespace directory
                OPENED      .word ?   ; The directory open request succeeded.
                VOLUME      .word ?   ; A volume record was found.
                FILE        .word ?   ; A file record was found.
                FREE        .word ?   ; A file-system free-space record was found.
                EOF         .word ?   ; All data has been read.
                CLOSED      .word ?   ; The directory file has been closed.
                ERROR       .word ?   ; An error occured; user should close.
                CREATED     .word ?   ; The directory has been created.
                DELETED     .word ?   ; The directory has been deleted.
            .endnamespace
            
            .namespace net
                TCP         .word ?
                UDP         .word ?
            .endnamespace
            
            .namespace timer
                EXPIRED     .word ?
            .endnamespace
            
            .namespace clock
                TICK        .word ?
            .endnamespace
        .endvirtual
    
    .endnamespace


    
    .namespace results
    
        .macro revent_t
            type       .byte ? ; Enum above
            buf        .byte ? ; page id or zero
            ext        .byte ? ; page id or zero
        .endmacro
    
        .struct key_type
            kernel.results.revent_t()
            keyboard   .byte ? ; Keyboard ID
            raw        .byte ? ; Raw key ID
            ascii      .byte ? ; ASCII value
            flags      .byte ? ; Flags (META)
                    META = $80 ; Meta key; no associated ASCII value.
        .endstruct
        
        .struct mouse_delta_type
            kernel.results.revent_t()
            x          .byte ?
            y          .byte ?
            z          .byte ?
            buttons    .byte ?
        .endstruct
        
        ; Data in mouse events
        .struct mouse_clicks_type
            kernel.results.revent_t()
            inner      .byte ?
            middle     .byte ?
            outer      .byte ?
        .endstruct
        
        ; Data in joystick events
        .struct joystick_type
            kernel.results.revent_t()
            joy0       .byte ?
            joy1       .byte ?
        .endstruct
        
        ; Data in file events:
        ; ext contains disk id
        .struct file_data_type
            kernel.results.revent_t()
            stream     .byte ?
            cookie     .byte ?
            requested  .byte ? ; Requested number of bytes to read
            read       .byte ? ; Number of bytes actually read
        .endstruct
        
        ; ext contains disk id
        .struct file_wrote_type
            kernel.results.revent_t()
            stream     .byte ?
            cookie     .byte ?
            requested  .byte ? ; Requested number of bytes to read
            wrote      .byte ? ; Number of bytes actually read
        .endstruct
        
        ; Data in directory events:
        ; ext contains disk id
        .struct dir_volume_type
            kernel.results.revent_t()
            stream     .byte ?
            cookie     .byte ?
            len        .byte ? ; Length of volname (in buf)
            flags      .byte ? ; block size, text encoding
        .endstruct
        
        ; ext contains byte count and modified date
        .struct dir_file_type
            kernel.results.revent_t()
            stream     .byte ?
            cookie     .byte ?
            len        .byte ?
            flags      .byte ? ; block scale, text encoding, approx size
        .endstruct
        
        ; ext contains byte count and modified date
        .struct dir_free_type
            kernel.results.revent_t()
            stream     .byte ?
            cookie     .byte ?
            flags      .byte ? ; block scale, text encoding, approx size
        .endstruct
        
        ; Extended information; more to follow.
        .struct dir_ext_type;
            kernel.results.revent_t()
            free       .fill 6 ; blocks used/free
        .endstruct
        
        
        ; Data in net events (major changes coming)
        .struct udp_type
            kernel.results.revent_t()
            token      .byte ? ; TODO: break out into fields
        .endstruct
        
        .struct tcp_type
            kernel.results.revent_t()
            len        .byte ? ; Raw packet length.
        .endstruct
        
        .struct timer_type
            kernel.results.revent_t()
            value      .byte ?
            cookie     .byte ?
        .endstruct
    
    .endnamespace

.endnamespace

.opt    nodotdirectives+ ,
        scopemacros+
