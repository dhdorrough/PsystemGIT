unit MyMessages;

interface

uses
  Messages;
  
const
  MSG_MOUNT_VOLUMES       = WM_USER + 3;
  MSG_UNMOUNT_ALL_VOLUMES = WM_USER + 4;
  MSG_CREATE_CSV_FILE_FROM_MOUNTED_VOLUMES = WM_USER +5;

var
  MessageBuffer: string[255];

implementation

end.
