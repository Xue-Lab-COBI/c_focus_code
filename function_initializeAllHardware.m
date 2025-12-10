function [Setup] = function_initializeAllHardware( varargin )
% The code is developed by Yi Xue, 4/3/2024
%% Initialize NI DAQ
Setup.Daq = daq("ni");
Setup.Daq.Rate = 2000000; %2MHz sample rate
addoutput(Setup.Daq,'Dev1','ao0','Voltage'); % galvo X
addoutput(Setup.Daq,'Dev1','ao1','Voltage'); % galvo Y
addoutput(Setup.Daq,'Dev1','ao2','Voltage'); %PMT gain 0.5-1V
addoutput(Setup.Daq,'Dev1','Port0/Line0:1','Digital');
addoutput(Setup.Daq,'Dev1','Port0/Line8','Digital'); % P0.8 (PMT +5)
AI0ch = addinput(Setup.Daq,'Dev1','ai0','Voltage'); % read from PMT 
AI0ch.TerminalConfig = 'SingleEnded'; %very important. default config is "differential" which is not used for PMT
disp('NI DAQ is initialized!');
%% initialize DMD
try
filename = 'alp4395.dll';
headname ='alp.h';
loadlibrary(filename, headname, 'alias', 'DMD');
catch
disp('Library is already loaded')
end

Setup.DMD.devicenumber=0;
Setup.DMD.deviceid = uint32(0);
Setup.DMD.deviceidptr = libpointer('uint32Ptr', Setup.DMD.deviceid);
Setup.DMD.initflag=0;
% Allocate DMD
[Setup.DMD.alp_returnvalue, Setup.DMD.deviceid] = calllib('DMD', 'AlpDevAlloc', ...
    Setup.DMD.devicenumber, Setup.DMD.initflag, Setup.DMD.initflag);
if Setup.DMD.alp_returnvalue~=0
    disp('Error allocate DMD: DMD are turned off or already on!');
end
% trigger-in read TTL rising edge
Setup.DMD.TriggerIn=2005;
Setup.DMD.TriggerEdge=2009;%rising 2009;falling edge 2008
Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpDevControl', ...
Setup.DMD.deviceid, Setup.DMD.TriggerIn, Setup.DMD.TriggerEdge);
if Setup.DMD.alp_returnvalue~=0
   disp('Error running DMD in the secondary mode!');
   Setup.DMD.alp_returnvalue=0;
end

Setup.DMD.sequenceid = [];
Setup.DMD.TriggerMode=2300; %2300: change primary(2301) or secondary (2302) mode
Setup.DMD.SequenceControl.RepeatMode=2100; 
Setup.DMD.SequenceControl.RepeatModeValue=1;
Setup.DMD.SequenceControl.BitplaneMode=2103; 
Setup.DMD.SequenceControl.BitplaneModeValue=1;

Setup.DMD.LY = 1280; 
Setup.DMD.LX = 800;
disp('DMD is initialized!');

% Load PI_MATLAB_Driver_GCS2
% Connection type
% use_RS232_Connection                = false;
% use_TCPIP_Connection                = false;
use_USB_Connection                  = true;

% Connection settings
% RS232
% comPort = 5;          % Look at the Device Manager to get the correct COM Port
% baudRate = 115200;    % Look at the manual to get the correct baud rate for your controller
% USB
controllerSerialNumber = '0424006119'; % Use "devicesUsb = Controller.EnumerateUSB('')" to get all PI controller connected to your PC. Or look at the label of the case of your controller
% TCP/IP
% ip = 'XXX.XXX.XXX.XX'; % Use "devicesTcpIp = Controller.EnumerateTCPIPDevices('')" to get all PI controller available on the network
% port = 50000;          % Is 50000 for almost all PI controllers


% Please choose the right configuration for your setup, 
% there is one common configuration working with most of PI controllers 
% and one configuration for the Hexapod controller C-887

axesSettings = 'Common'; % 'Common' 'C-887'
switch axesSettings
    case 'Common'
        Setup.PIaxis = '1';
    case 'C-887'
        Setup.PIaxis = 'X';
end
    
isWindows   = any (strcmp (mexext, {'mexw32', 'mexw64'}));

if (isWindows)
    matlabDriverPath = getenv ('PI_MATLAB_DRIVER');
    if (~exist(matlabDriverPath,'dir'))
        error('The PI MATLAB Driver GCS2 was not found on your system. Probably it is not installed. Please run PISoftwareSuite.exe to install the driver.');
    else
        addpath(matlabDriverPath);
    end
else
    if (~exist('/usr/local/PI/pi_matlab_driver_gcs2','dir'))
        error('The PI MATLAB Driver GCS2 was not found on your system. If you need the MATLAB driver for Linux please contact the service.');
    else
        addpath ('/usr/local/PI/pi_matlab_driver_gcs2');
    end
end

% Load PI_GCS_Controller if not already loaded
if(~exist('Setup.PIController','var'))
    Setup.PIController = PI_GCS_Controller();
end
% if(~isa('Setup.PIController','PI_GCS_Controller'))
%     Setup.PIController = PI_GCS_Controller();
% end

% Get the PI_MATLAB_Driver_GCS2 Version Number
% if (isWindows)
%     Controller.GetVersionNumber()
% end
% disp ('PI MATLAB driver is set up properly!');
 boolPIdeviceConnected = false; 
    if ( exist ( 'Setup.PIdevice', 'var' ) ), if ( Setup.PIdevice.IsConnected ), boolPIdeviceConnected = true; end; end
    if ( ~(boolPIdeviceConnected ) )
        if(use_USB_Connection)                               
            Setup.PIdevice = Setup.PIController.ConnectUSB ( controllerSerialNumber );
        end
    end
 % query controller identification string
    Setup.PIconnectedControllerName = Setup.PIdevice.qIDN();

    % initialize PIdevice object for use in MATLAB
    Setup.PIdevice = Setup.PIdevice.InitializeController ();
    switchOn    = 1;
    Setup.PIdevice.SVO ( Setup.PIaxis, switchOn );
    Setup.PIposition.minimumPosition = Setup.PIdevice.qTMN ( Setup.PIaxis );
    Setup.PIposition.maximumPosition = Setup.PIdevice.qTMX ( Setup.PIaxis );
    Setup.PIposition.travelRange = ( Setup.PIposition.maximumPosition - Setup.PIposition.minimumPosition );
    disp(['PI stage is switched on, minimum position ' num2str(Setup.PIposition.minimumPosition) ', maximum position '...
        num2str(Setup.PIposition.maximumPosition)]);
end

