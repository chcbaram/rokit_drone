import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
import processing.serial.*;


CoDroneClass CoDrone = new CoDroneClass();
   
Serial serial_port = null;








public class CoDroneClass {
  
  boolean bConnected = false;
  
  int linkState = 0;;
  int rssi = 0;
  byte battery = 0;  
  byte irMassageDirection;
  long  irMassageReceive;
 

  byte displayMode = 1;  //smar inventor : default 1
  byte debugMode = 0;    //smar inventor : default 0
  
  byte discoverFlag;
  byte connectFlag;
      
  boolean pairing = false;
  
  int SendInterval; //millis seconds    
  int analogOffset;
  byte displayLED = 0;

  byte timeOutRetry = 0;
  
  byte sendCheckFlag = 0;
  
  byte receiveAttitudeSuccess = 0;
  
  int energy = 8;
  
  
  
  
  
  int PreviousMillis;
  int timeOutSendPreviousMillis;
  
  byte[] cmdBuff  = new byte[100];
  byte[] dataBuff = new byte[100];
  byte[] crcBuff  = new byte[2];
  
  byte checkHeader;
  int cmdIndex = 0;
  int receiveDtype;
  int receiveLength;
  int receiveEventState;
  int receiveLinkState;
  int receiveLikMode;
  int receiveComplete;
  int receiveCRC;  
  
  
  byte devCount = 0;
  byte[] devFind = new byte[3];
  
  int devRSSI0 = -1;
  int devRSSI1 = -1;
  int devRSSI2 = -1;
    
  byte[] devName0 = new byte[40];
  byte[] devName1   = new byte[40];
  byte[] devName2   = new byte[40];
    
  byte[] devAddress0 = new byte[6];
  byte[] devAddress1 = new byte[6];
  byte[] devAddress2 = new byte[6];
  
  byte[] devAddressBuf = new byte[6];
  byte[] devAddressConnected = new byte[6];
  
  byte[] droneState = new byte[7];  
  byte[] droneIrMassage = new byte[5];  
  
  byte[] droneAttitude = new byte[6];
  byte[] droneGyroBias = new byte[6];
  byte[] droneTrimAll = new byte[10];    
  byte[] droneTrimFlight = new byte[8];
  byte[] droneTrimDrive = new byte[2];
  byte[] droneImuRawAndAngle = new byte[9];
  byte[] dronePressure = new byte[16];  
  byte[] droneImageFlow = new byte[8];
  byte[] droneButton = new byte[1];
  byte[] droneBattery = new byte[16];
  byte[] droneMotor = new byte[4];
  byte[] droneTemperature = new byte[8];
  
  int roll = 0;
  int pitch = 0;
  int yaw = 0;
  int throttle = 0;
    
  int attitudeRoll  = 0;
  int attitudePitch  = 0;
  int attitudeYaw  = 0;
  
  
  
  public CoDroneClass() {        
  }

  public void begin( int baud ) {
    println("begin");
    
    cmdIndex = 0;    
    //Link Active Mode
    Send_LinkModeBroadcast(LinkBroadcast_Active);    
    delay(500);
  }
    
  void Send_LinkModeBroadcast(byte mode)
  {
    Send_Command(cType_LinkModeBroadcast, mode);
  }

  void Request_DroneAttitude()
  {
    sendCheckFlag = 1;
    Send_Command(cType_Request, Req_Attitude);    
  }


  void Request_DroneGyroBias()
  {
    Send_Command(cType_Request, Req_GyroBias);    
  }
  void Request_TrimAll()
  {
    sendCheckFlag = 1;
    Send_Command(cType_Request, Req_TrimAll);    
  }
  void Request_TrimFlight()
  {
    Send_Command(cType_Request, Req_TrimFlight);    
  }
  void Request_TrimDrive()
  {
    Send_Command(cType_Request, Req_TrimDrive);    
  }
  void Request_ImuRawAndAngle()
  {
    Send_Command(cType_Request, Req_ImuRawAndAngle);    
  }
  void Request_Pressure()
  {
    Send_Command(cType_Request, Req_Pressure);    
  }
  void Request_ImageFlow()
  {
    Send_Command(cType_Request, Req_ImageFlow);    
  }
  void Request_Button()
  {
    Send_Command(cType_Request, Req_Button);    
  }
  void Request_Battery()
  {
    Send_Command(cType_Request, Req_Batery);    
  }
  void Request_Motor()
  {
    Send_Command(cType_Request, Req_Motor);    
  }
  void Request_Temperature()
  {
    Send_Command(cType_Request, Req_Temperature);    
  }

  void DroneModeChange(byte event)
  {
      sendCheckFlag = 1;
      Send_Command(cType_ModeDrone, event);
      delay(300);
  }

  void FlightEvent(byte event)
  {
    sendCheckFlag = 1;
    Send_Command(cType_FlightEvent, event);
  }

  void Control(int interval)
  {
      if (TimeCheck(interval))  //delay
      {
        Control();
        PreviousMillis = millis();
      }
  }

  void Control()
  {  
    byte[] _packet = new byte[10];
    byte[] _crc = new byte[2];
    
    byte _cType = dType_Control;
    byte _len = 4;
    
    //header
    _packet[0] = _cType;
    _packet[1] = _len;
  
    //data
    _packet[2] = byte(roll);
    _packet[3] = byte(pitch);
    _packet[4] = byte(yaw);
    _packet[5] = byte(throttle);
  
    int crcCal = CRC16_Make(_packet, _len+2);
    crcCal = crcCal & 0xFFFF;
    _crc[0] = byte((crcCal >> 8) & 0xff);
    _crc[1] = byte(crcCal & 0xff);
    
    Send_Processing(_packet,_len,_crc);  
    
    roll = 0;
    pitch = 0;
    yaw = 0;
    throttle = 0;
    
    ////////////////////////////////////////////
    sendCheckFlag = 0;
    ////////////////////////////////////////////
    
    Send_Check(_packet,_len,_crc);
    
    /*
    if(sendCheckFlag == 1)
    {
      timeOutSendPreviousMillis = millis();
      
       while(sendCheckFlag != 3)
       {
         while(!TimeOutSendCheck(3))
        {
          Receive();
          if(sendCheckFlag == 3) break;
        }
        if(sendCheckFlag == 3) break;
              
        Send_Processing(_packet,_len,_crc);
       }
      sendCheckFlag = 0;
    }
    */
  ///////////////////////////////////////////  
  }


  void Receive()
  {    
    /*
    if (serial_port.available() > 0)
    {
      int input = serial_port.read();
      
      if(debugMode == 1)
      {
        print("RX:");
        println(hex(input));        
      }  
      
      cmdBuff[cmdIndex++] = byte(input);
  
      if (cmdIndex >= MAX_PACKET_LENGTH)
      {
        checkHeader = 0;
        cmdIndex = 0;
      }
      else
      {
        if (cmdIndex == 1)
        {
          if (cmdBuff[0] == START1)  checkHeader = 1;
          else
          {
            checkHeader = 0;
            cmdIndex = 0;
          }
        }
        else if (cmdIndex == 2)
        {
          if (checkHeader == 1)
          {
            if (cmdBuff[1] == START2)  checkHeader = 2;
            else
            {
              checkHeader = 0;
              cmdIndex = 0;
            }
          }
        }      
        else if (checkHeader == 2)
        {
          if (cmdIndex == 3)
          {
            receiveDtype =  cmdBuff[2];
            dataBuff[cmdIndex - 3] = cmdBuff[cmdIndex - 1];
          }
          else if (receiveDtype != dType_StringMessage) //not message string
          {
            if (cmdIndex == 4)
            {
              receiveLength = cmdBuff[3];
              dataBuff[cmdIndex - 3] = cmdBuff[cmdIndex - 1];
            }
            else if (cmdIndex > 4)
            {
              if (receiveLength + 5 > cmdIndex)     dataBuff[cmdIndex - 3] = cmdBuff[cmdIndex - 1];     
                     
              else if (receiveLength + 6 > cmdIndex)  crcBuff[0]  = cmdBuff[cmdIndex - 1];
              
              else if (receiveLength + 6 <= cmdIndex)
              {
                crcBuff[1]  = cmdBuff[cmdIndex - 1];
  
                if (CRC16_Check(dataBuff, receiveLength, crcBuff))  receiveComplete = 1;
                else  receiveComplete = -1;
  
                if (receiveComplete == 1)
                {                         
                  println("receiveComplete");
                }
                checkHeader = 0;
                cmdIndex = 0;
              }
            }
          }
          else
          {
            checkHeader = 0;
            cmdIndex = 0;
          }
        }
      }
    }
    //ReceiveEventCheck();
    */
  }

  void ReceiveData(int ch)
  {        
    {
      int input = ch;
      
      if(debugMode == 1)
      {
        //print("RX:");
        //print(cmdIndex);
        //print(" ");
        //println(hex(input));        
      }  
      
      cmdBuff[cmdIndex++] = byte(input);
  
      if (cmdIndex >= MAX_PACKET_LENGTH)
      {
        checkHeader = 0;
        cmdIndex = 0;
      }
      else
      {
        if (cmdIndex == 1)
        {
          if (cmdBuff[0] == START1)  checkHeader = 1;
          else
          {
            checkHeader = 0;
            cmdIndex = 0;
          }
        }
        else if (cmdIndex == 2)
        {
          if (checkHeader == 1)
          {
            if (cmdBuff[1] == START2)  checkHeader = 2;
            else
            {
              checkHeader = 0;
              cmdIndex = 0;
            }
          }
        }      
        else if (checkHeader == 2)
        {
          if (cmdIndex == 3)
          {
            receiveDtype =  cmdBuff[2];
            dataBuff[cmdIndex - 3] = cmdBuff[cmdIndex - 1];
          }
          else if (receiveDtype != dType_StringMessage) //not message string
          {
            if (cmdIndex == 4)
            {
              receiveLength = cmdBuff[3];
              dataBuff[cmdIndex - 3] = cmdBuff[cmdIndex - 1];
            }
            else if (cmdIndex > 4)
            {
              if (receiveLength + 5 > cmdIndex)     dataBuff[cmdIndex - 3] = cmdBuff[cmdIndex - 1];     
                     
              else if (receiveLength + 6 > cmdIndex)  crcBuff[0]  = cmdBuff[cmdIndex - 1];
              
              else if (receiveLength + 6 <= cmdIndex)
              {
                crcBuff[1]  = cmdBuff[cmdIndex - 1];
  
                if (CRC16_Check(dataBuff, receiveLength, crcBuff))  receiveComplete = 1;
                else  receiveComplete = -1;
  
                if (receiveComplete == 1)
                { 
                  if(debugMode == 1)
                  {
                    println("receiveComplete");
                  }
                  
                  ProcessReceiveType();          
                  
                }
                checkHeader = 0;
                cmdIndex = 0;
              }
            }
          }
          else
          {
            checkHeader = 0;
            cmdIndex = 0;
          }
        }
      }
    }
    ReceiveEventCheck();
  }


  void ProcessReceiveType()
  {
    
                if (receiveDtype == dType_LinkState)    
                {
                  receiveLinkState = dataBuff[2];
                  receiveLikMode = dataBuff[3];                  
                }                                  
                else if (receiveDtype == dType_LinkEvent)    
                {
                  receiveEventState = dataBuff[2];
                }
                          
                /***********************************************/     
                           
                else if (receiveDtype == dType_IrMessage)    //IrMessage
                {             
                  droneIrMassage[0] = dataBuff[2];
                  droneIrMassage[1] = dataBuff[3];
                  droneIrMassage[2] = dataBuff[4];
                  droneIrMassage[3] = dataBuff[5];
                  droneIrMassage[4] = dataBuff[6];                
                }                          
                         
                else if (receiveDtype == dType_State)    //dron state
                {             
                  droneState[0] = dataBuff[2];
                  droneState[1] = dataBuff[3];
                  droneState[2] = dataBuff[4];
                  droneState[3] = dataBuff[5];
                  droneState[4] = dataBuff[6];
                  droneState[5] = dataBuff[7];  
                  droneState[6] = dataBuff[8];                    
                }
                else if (receiveDtype == dType_Attitude)    //dron Attitude
                { 
                  droneAttitude[0] = dataBuff[2];
                  droneAttitude[1] = dataBuff[3];
                  droneAttitude[2] = dataBuff[4];
                  droneAttitude[3] = dataBuff[5];
                  droneAttitude[4] = dataBuff[6];
                  droneAttitude[5] = dataBuff[7];                                                                        
                }      
                
                else if (receiveDtype == dType_GyroBias)    //dron GyroBias
                { 
                  droneGyroBias[0] = dataBuff[2];
                  droneGyroBias[1] = dataBuff[3];
                  droneGyroBias[2] = dataBuff[4];
                  droneGyroBias[3] = dataBuff[5];
                  droneGyroBias[4] = dataBuff[6];
                  droneGyroBias[5] = dataBuff[7];                                 
                }                 
                                
                else if (receiveDtype == dType_TrimAll)    //dron TrimAll
                { 
                  droneTrimAll[0] = dataBuff[2];
                  droneTrimAll[1] = dataBuff[3];
                  droneTrimAll[2] = dataBuff[4];
                  droneTrimAll[3] = dataBuff[5];
                  droneTrimAll[4] = dataBuff[6];
                  droneTrimAll[5] = dataBuff[7];                  
                  droneTrimAll[6] = dataBuff[8];
                  droneTrimAll[7] = dataBuff[9];
                  droneTrimAll[8] = dataBuff[10];
                  droneTrimAll[9] = dataBuff[11];                                              
                }           
                                
                else if (receiveDtype == dType_TrimFlight)    //dron TrimFlight
                { 
                  droneTrimFlight[0] = dataBuff[2];
                  droneTrimFlight[1] = dataBuff[3];
                  droneTrimFlight[2] = dataBuff[4];
                  droneTrimFlight[3] = dataBuff[5];
                  droneTrimFlight[4] = dataBuff[6];
                  droneTrimFlight[5] = dataBuff[7];                  
                  droneTrimFlight[6] = dataBuff[8];
                  droneTrimFlight[7] = dataBuff[9];                                    
                }                    
                
                else if (receiveDtype == dType_TrimDrive)    //dron TrimDrive
                { 
                  droneTrimDrive[0] = dataBuff[2];
                  droneTrimDrive[1] = dataBuff[3];                                         
                }    
                
                else if (receiveDtype == dType_ImuRawAndAngle)//dron ImuRawAndAngle
                {
                  droneImuRawAndAngle[0] = dataBuff[2];
                  droneImuRawAndAngle[1] = dataBuff[3];
                  droneImuRawAndAngle[2] = dataBuff[4];
                  droneImuRawAndAngle[3] = dataBuff[5];
                  droneImuRawAndAngle[4] = dataBuff[6];
                  droneImuRawAndAngle[5] = dataBuff[7];       
                  droneImuRawAndAngle[6] = dataBuff[8];        
                   droneImuRawAndAngle[7] = dataBuff[9];       
                  droneImuRawAndAngle[8] = dataBuff[10];                                           
                }
                
                else if (receiveDtype == dType_Pressure)//dron Pressure
                {
                  dronePressure[0] = dataBuff[2];
                  dronePressure[1] = dataBuff[3];  
                  dronePressure[2] = dataBuff[4];  
                  dronePressure[3] = dataBuff[5];
                  dronePressure[4] = dataBuff[6];
                  dronePressure[5] = dataBuff[7];
                  dronePressure[6] = dataBuff[8];
                  dronePressure[7] = dataBuff[9];
                  dronePressure[8] = dataBuff[10];
                  dronePressure[9] = dataBuff[11];
                  dronePressure[10] = dataBuff[12];
                  dronePressure[11] = dataBuff[13];
                  dronePressure[12] = dataBuff[14];
                  dronePressure[13] = dataBuff[15];
                  dronePressure[14] = dataBuff[16];
                  dronePressure[15] = dataBuff[17];
                }
                
                else if (receiveDtype ==  dType_ImageFlow)//dron ImageFlow
                {
                  droneImageFlow[0] = dataBuff[2];
                  droneImageFlow[1] = dataBuff[3]; 
                  droneImageFlow[2] = dataBuff[4];
                  droneImageFlow[3] = dataBuff[5]; 
                  droneImageFlow[4] = dataBuff[6];
                  droneImageFlow[5] = dataBuff[7]; 
                  droneImageFlow[6] = dataBuff[8];
                  droneImageFlow[7] = dataBuff[9];                   
                }
                     
                else if (receiveDtype ==  dType_Button)//dron Button
                {
                  droneButton[0] = dataBuff[2];
                }
                       
                else if (receiveDtype ==  dType_Batery)//dron Batery
                {
                  droneBattery[0] = dataBuff[2];
                  droneBattery[1] = dataBuff[3];  
                  droneBattery[2] = dataBuff[4];  
                  droneBattery[3] = dataBuff[5];
                  droneBattery[4] = dataBuff[6];
                  droneBattery[5] = dataBuff[7];
                  droneBattery[6] = dataBuff[8];
                  droneBattery[7] = dataBuff[9];
                  droneBattery[8] = dataBuff[10];
                  droneBattery[9] = dataBuff[11];
                  droneBattery[10] = dataBuff[12];
                  droneBattery[11] = dataBuff[13];
                  droneBattery[12] = dataBuff[14];
                  droneBattery[13] = dataBuff[15];
                  droneBattery[14] = dataBuff[16];
                  droneBattery[15] = dataBuff[17];                        
                }    
                                          
                else if (receiveDtype ==  dType_Motor)//dron Motor
                {
                  droneMotor[0] = dataBuff[2];
                  droneMotor[1] = dataBuff[3];
                  droneMotor[2] = dataBuff[4];
                  droneMotor[3] = dataBuff[5];                  
                }            
                     
                else if (receiveDtype ==  dType_Temperature)//dron Temperature
                {
                  droneTemperature[0] = dataBuff[2];
                  droneTemperature[1] = dataBuff[3];
                  droneTemperature[2] = dataBuff[4];
                  droneTemperature[3] = dataBuff[5];
                  droneTemperature[4] = dataBuff[6];
                  droneTemperature[5] = dataBuff[7];
                  droneTemperature[6] = dataBuff[8];
                  droneTemperature[7] = dataBuff[9];
                }    
                
                /***********************************************/                  
                else if (receiveDtype == dType_LinkRssi)//Discovered Device
                {
                  rssi = dataBuff[2];
                  rssi = rssi - 256;
                                    
                  if(debugMode == 1)
                  {    
                    print("RSSI : ");  
                    println(rssi);                    
                  }
                }
                /***********************************************/                                 
                else if (receiveDtype == dType_LinkDiscoveredDevice)//Discovered Device
                {
                  byte devIndex = dataBuff[2];

                  print("dType_LinkDiscoveredDevice : ");
                  println(devIndex);

                  if (devIndex == 0)
                  {
                    for (int i = 3; i <= 8; i++)
                    {
                      devAddress0[i - 3] = dataBuff[i];
                    }
                    
                    for (int i = 9; i <= 28; i++)
                    {
                      devName0[i - 3] = dataBuff[i];
                    }
                                                            
                    devRSSI0 = dataBuff[29];
                    devFind[0] = 1; 
                  }
                  else if (devIndex == 1)
                  {
                    for (int i = 3; i <= 8; i++)
                    {
                      devAddress1[i - 3] = dataBuff[i];
                    }
                    
                    for (int i = 9; i <= 28; i++)
                    {
                      devName1[i - 3] = dataBuff[i];
                    }
                    
                    devRSSI1 = dataBuff[29];
                    devFind[1] = 1;
                  }
                  else if (devIndex == 2)
                  {
                    for (int i = 3; i <= 8; i++)
                    {
                      devAddress2[i - 3] = dataBuff[i];
                    }
                    
                    for (int i = 9; i <= 28; i++)
                    {
                      devName2[i - 3] = dataBuff[i];
                    }
                    
                    devRSSI2 = dataBuff[29];
                    devFind[2] = 1;   
                  }

                  devCount = byte(devFind[0] +  devFind[1] +  devFind[2]);
                  
                  print("devCount : ");
                  print(devFind[0]);
                  print(" ");
                  print(devFind[1]);
                  print(" ");
                  print(devFind[2]);
                  print(" ");
                  println(devCount);
                  
                  if(debugMode == 1)
                  {                    
                    DisplayAddress(devCount); //Address display                    
                  }               
                }    
  }


  void Send_LinkState()
  {
    Send_Command(cType_Request, dType_LinkState);
  }

  void LinkStateCheck()  //ready or connected ?
  {
    int tTime;
    int time = 100;
    
    linkState = -1;
    Send_LinkState();
  
    delay(50);
   
   tTime = millis();
    while (linkState <= 0)   
    {
      Receive();
      time--;
      
      //println(time);
      //println((millis()-tTime));
      
      //if( time == 0 ) break;
      if( (millis()-tTime) > 1000 ) break;
    }  
  }


  void Send_Discover(byte action)
  {  
    if(action == cType_LinkDiscoverStop)      
    {
      Send_Command(cType_LinkDiscoverStop, byte(0));    //DiscoverStop
    }
    else if(action == cType_LinkDiscoverStart)  
    {
      Send_Command(cType_LinkDiscoverStart, byte(0));    //DiscoverStart  
      discoverFlag = 1;
    }
  }
  
  
  void Send_ConnectNearbyDrone()
  {
    println("Send_ConnectNearbyDrone");
    
    if (devCount > 0)
    {
      print(devRSSI0);
      print(" ");
      print(devRSSI1);
      print(" ");
      print(devRSSI2);
      print(" ");
      
      Send_Connect(byte(0));
      /*
      if (devRSSI0 > devRSSI1)
      {
        if (devRSSI0 > devRSSI2)  Send_Connect(byte(0));     
        else      Send_Connect(byte(2));
      }
      else
      {
        if (devRSSI1 > devRSSI2)   Send_Connect(byte(1));
        else       Send_Connect(byte(2));
      }
      */
    }
  }  
  
  
  void Send_Connect(byte index) //index 0, 1, 2
  {
    connectFlag = 1;
      
    print("Send_Connect : ");
    println(index);  
      
    if(index == 0)
    {        
      for (int i = 0; i <= 5; i++)    devAddressBuf[i] = devAddress0[i];
    }  
    else if (index == 1)
    {
      for (int i = 0; i <= 5; i++)    devAddressBuf[i] = devAddress1[i];
    }
    else if (index == 2)
    {
      for (int i = 0; i <= 5; i++)    devAddressBuf[i] = devAddress2[i];
    }  
    
    Send_Command(cType_LinkConnect, index);
  }


  boolean TimeCheck(int interval) //milliseconds
  {
    boolean time = false;
    int currentMillis = millis();
    if (currentMillis - PreviousMillis > interval)
    {
      PreviousMillis = currentMillis;
      time = true;
    }
    return time;
  }

  boolean TimeOutSendCheck(int interval) //milliseconds
  {
    boolean time = false;
    int currentMillis = millis();
    if (currentMillis - timeOutSendPreviousMillis > interval)
    {
      timeOutSendPreviousMillis = currentMillis;
      time = true;
    }
    return time;
  }

  void Send_ConnectConnectedDrone()
  {  
    if (devCount > 0)
    {
      //ConnectedDrone same address check
      byte AddrCheck0 = 0;
      byte AddrCheck1 = 0;
      byte AddrCheck2 = 0;
      
      for (int i = 0; i <= 5; i++)
      {
        if (devAddressConnected[i] == devAddress0[i])  AddrCheck0++;
        if (devAddressConnected[i] == devAddress1[i])  AddrCheck1++;
        if (devAddressConnected[i] == devAddress2[i])  AddrCheck2++;
      }    
      if(AddrCheck0 == 6)  Send_Connect(byte(0));   
      else if(AddrCheck1 == 6)  Send_Connect(byte(1));   
      else if(AddrCheck2 == 6)  Send_Connect(byte(2));    
    }  
  }


  void AutoConnect(byte mode)
  {  
    // Connected check
    LinkStateCheck();    
    if (linkState  == linkMode_Connected)
    {
      pairing = true;
      //LED_Connect();    
    }
    // AutoConnect start
    else     
    {        
      if (mode == NearbyDrone)  
      {
        println("NearbyDrone in");
        
        Send_Discover(cType_LinkDiscoverStart);  
        PreviousMillis = millis();
        println("NearbyDrone");
        
        while(!pairing)
        {      
          if((discoverFlag == 3) && (connectFlag == 0)) //Address find
          {
             println("step 1");
             delay(50);
             discoverFlag = 0;
             Send_ConnectNearbyDrone();                   //  Connect Start
          }          
          else if (discoverFlag == 4)  // Address not find : re-try
          {
             println("step 2");
             delay(50);
             Send_Discover(cType_LinkDiscoverStart);
             PreviousMillis = millis();
          }
          else
          {      
            if (TimeCheck(400))    //time out & LED
            {
              if (displayLED++ == 4) 
              {
                println("step 3");
                displayLED = 0;   
                delay(50);     
                Send_Discover(cType_LinkDiscoverStart);
              }
              PreviousMillis = millis();            
            }
          }              
          Receive();  
        }
        delay(50);           
      }      
      else if(mode == ConnectedDrone)   
      {
        Send_Discover(cType_LinkDiscoverStart);  
        PreviousMillis = millis();
                
        while(!pairing)
        {      
          
         if ((discoverFlag == 3) && (connectFlag == 0))  //Address find
         {                           
           delay(50);
           discoverFlag = 0;
           Send_ConnectConnectedDrone();       //  Connect Start        
         }
         else if (discoverFlag == 4)  // Address not find : re-try
         {
           Send_Discover(cType_LinkDiscoverStart);
          PreviousMillis = millis();
         }
         else
         {      
          if (TimeCheck(400))  //time out & LED
          {
            if (displayLED++ == 4) 
            {
              displayLED = 0;   
              delay(50);     
              Send_Discover(cType_LinkDiscoverStart);
            }
            PreviousMillis = millis();            
          }
        }
           Receive();      
        }
        delay(50);
      } 
    }
  }
  
  
  void Send_Check(byte _data[], byte _length, byte _crc[])
  {
    if(sendCheckFlag == 1)
    {
      timeOutSendPreviousMillis = millis();
      
       while(sendCheckFlag != 3)
       {
         while(!TimeOutSendCheck(byte(SEND_CHECK_TIME)))
        {
          Receive();
          if(sendCheckFlag == 3) break;
        }
        if(sendCheckFlag == 3) break;
        
        Send_Processing(_data,_length,_crc);
       }
      sendCheckFlag = 0;
    }  
  }

  void Send_Command(byte sendCommand, byte sendOption)
  {  
    byte[] _packet = new byte[9];
    byte[] _crc = new byte[2];
    
    byte _cType = dType_Command;
    byte _len   = 0x02;  
    
    //header
    _packet[0] = _cType;
    _packet[1] = _len;
  
   //data
    _packet[2] = byte(sendCommand);
    _packet[3] = byte(sendOption);
    
   int crcCal = CRC16_Make(_packet, _len+2);
      
    _crc[0] = byte((crcCal >> 8) & 0xff);
    _crc[1] = byte(crcCal & 0xff);
    
    Send_Processing(_packet,_len,_crc);
    Send_Check(_packet,_len,_crc);    
  }


  void Send_Processing(byte _data[], byte _length, byte _crc[])
  {    
    byte[] _packet = new byte[30];
    int i;
    
    //START CODE  
    _packet[0] = START1;
    _packet[1] = START2;
  
    //HEADER & DATA
    for(i = 0; i < _length + 3 ; i++)
    {
     _packet[i+2] = _data[i];     
    }
    //CRC  
    _packet[_length + 4] =_crc[1];
    _packet[_length + 5] =_crc[0]; 
    
    for( i=0; i<_length+6; i++ )
    {
      if( serial_port != null )
      {
         serial_port.write(_packet[i]);
      }
    }
         
    if(debugMode == 1)
    {
      //print("> SEND : ");
      
      for(i = 0; i < _length+6 ; i++)
      {
        //print(hex(_packet[i]));      
        //print(" ");       
      }
      //println("");  
    }  
  }
  
  
  void DisplayAddress(byte count)
  {  
    if(debugMode == 1)
    {                                          
      if (count == 1)       print("index 0 - ADRESS : ");
      else if (count == 2)  print("index 1 - ADRESS : ");
      else if (count == 3)  print("index 2 - ADRESS : ");
    
      for (int i = 0; i <= 5; i++)
      {
        if (count == 1)
        {
          print(hex(devAddress0[i]));
          if(i < 5)  print(", ");
        }      
        else if (count == 2)
        {
          print(hex(devAddress1[i])); 
          if(i < 5)  print(", ");
        }        
        else if (count == 3)
        {
          print(hex(devAddress2[i])); 
          if(i < 5)  print(", ");
        }
      }
      print("\t");
      print("NAME :");
          
       for (int i = 0; i <= 19; i++)
      {
        if (count == 1)
        {
          print(char(devName0[i]));
        }      
        else if (count == 2)
        {
          print(char(devName1[i]));
        }        
        else if (count == 3)
        {
          print(char(devName2[i]));
        }
      }            
              
      print(" RSSI : ");
      
      if (count == 1)       println(devRSSI0 - 256);
      else if (count == 2)  println(devRSSI1 - 256);
      else if (count == 3)  println(devRSSI2 - 256);              
    }  
    
  }

  
  void ReceiveEventCheck()
  {
  /***************************************************************/
    
  if(receiveComplete > 0)
  {
    /**************************************************************/  
    
    if (receiveDtype == dType_State)
    {
      if (droneState[0] != 0 )
      {                 
          if(debugMode == 1)
          { 
            println("");
            println("- Request Drone State");
                
            print("ModeDrone \t");
            
            if(droneState[0] == dMode_None)                    println("None");
            else if(droneState[0] == dMode_Flight)            println("Flight");
            else if(droneState[0] == dMode_FlightNoGuard)      println("FlightNoGuard");
            else if(droneState[0] == dMode_FlightFPV)          println("FlightFPV");
            else if(droneState[0] == dMode_Drive)              println("Drive");
            else if(droneState[0] == dMode_DriveFPV)          println("DriveFPV");
            else if(droneState[0] == dMode_Test)              println("Test");
            
            print("ModeVehicle \t");  
              
            if(droneState[1] == vMode_None)                    println("None");
            else if(droneState[1] == vMode_Boot)              println("Boot");
            else if(droneState[1] == vMode_Wait)              println("Wait");
            else if(droneState[1] == vMode_Ready)              println("Ready");
            else if(droneState[1] == vMode_Running)            println("Running");
            else if(droneState[1] == vMode_Update)            println("Update");
            else if(droneState[1] == vMode_UpdateComplete)    println("UpdateComplete");
            else if(droneState[1] == vMode_Error)              println("Error");
            
            print("ModeFlight \t");  
            
            if(droneState[2] == fMode_None)                    println("None");
            else if(droneState[2] == fMode_Ready)              println("Ready");
            else if(droneState[2] == fMode_TakeOff)            println("TakeOff");
            else if(droneState[2] == fMode_Flight)            println("Flight");
            else if(droneState[2] == fMode_Flip)              println("Flip");
            else if(droneState[2] == fMode_Stop)              println("Stop");
            else if(droneState[2] == fMode_Landing)            println("Landing");
            else if(droneState[2] == fMode_Reverse)            println("Reverse");
            else if(droneState[2] == fMode_Accident)          println("Accident");
            else if(droneState[2] == fMode_Error)              println("Error");
                
            print("ModeDrive \t");  
                    
            if(droneState[3] == dvMode_None)                  println("None");
            else if(droneState[3] == dvMode_Ready)            println("Ready");
            else if(droneState[3] == dvMode_Start)            println("Start");
            else if(droneState[3] == dvMode_Drive)            println("Drive");
            else if(droneState[3] == dvMode_Stop)              println("Stop");
            else if(droneState[3] == dvMode_Accident)          println("Accident");
            else if(droneState[3] == dvMode_Error)            println("Error");
                      
            print("SensorOrientation \t");      
            
            if(droneState[4] == senOri_None)                  println("None");
            else if(droneState[4] == senOri_Normal)            println("Normal");
            else if(droneState[4] == senOri_ReverseStart)      println("ReverseStart");
            else if(droneState[4] == senOri_Reverse)          println("Reverse");
                  
            print("Coordinate \t");  
                                  
            if(droneState[5] == cSet_None)                    println("None");
            else if(droneState[5] == cSet_Absolute)            println("Absolute");
            else if(droneState[5] == cSet_Relative)            println("Relative");
            
            print("Battery \t");  
            println(droneState[6]);
                    
        }  
            
                
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;  
      }    
    }
    
    /**************************************************************/
    
     else if (receiveDtype == dType_IrMessage)    //IrMessage
     {
       
       irMassageDirection  = droneIrMassage[0];
       
       int[] _irMassge = new int[4];
       
       _irMassge[0] = droneIrMassage[1];
       _irMassge[1] = droneIrMassage[2];
       _irMassge[2] = droneIrMassage[3];
       _irMassge[3] = droneIrMassage[4];
              
       irMassageReceive  = ((_irMassge[3] << 24) | (_irMassge[2] << 16) | (_irMassge[1] << 8) | (_irMassge[0]  & 0xff));
          
      
      if(debugMode == 1)
      {                   
        println("");                                  
        println("- IrMassage");
        print("[ ");
        print(hex(droneIrMassage[0]));
        print(", ");
        print(hex(droneIrMassage[1]));
        print(", ");
        print(hex(droneIrMassage[2]));
        print(", ");
        print(hex(droneIrMassage[3]));
        print(", ");
        print(hex(droneIrMassage[4]));    
        println(" ]");
        
        print("IrMassageDirection\t");          
        print(irMassageDirection);
        
        if(irMassageDirection == 1)        println(" (Left)");
        else if (irMassageDirection == 2)  println(" (Front)");
        else if (irMassageDirection == 3)  println(" (Right)");
        else if (irMassageDirection == 4)  println(" (Rear)");
        else println("None");
                
        print("IrMassageReceive\t");  
        println(irMassageReceive);
                                          
      }  
      
      receiveEventState = -1;    
      receiveComplete = -1;
      receiveLength = -1;
      receiveLinkState = -1;
      receiveDtype = -1;  
      
                  
     }                          
      /**************************************************************/
    else if (receiveDtype == dType_Attitude)
    {        
            
        attitudeRoll    = ((droneAttitude[1] << 8) | (droneAttitude[0]  & 0xff));
        attitudePitch  = ((droneAttitude[3] << 8) | (droneAttitude[2]  & 0xff));
        attitudeYaw    = ((droneAttitude[5] << 8) | (droneAttitude[4]  & 0xff));
        
        receiveAttitudeSuccess = 1;
                                          
                                   
                                                    
        if(debugMode == 1)
        {           
          println("");                                  
          println("- Attitude");
          print("[ ");
          print(hex(droneAttitude[0]));
          print(", ");
          print(hex(droneAttitude[1]));
          print(", ");
          print(hex(droneAttitude[2]));
          print(", ");
          print(hex(droneAttitude[3]));
          print(", ");
          print(hex(droneAttitude[4]));
          print(", ");
          print(hex(droneAttitude[5]));        
          println(" ]");
          


          print("ROLL\t");  
          println(attitudeRoll);
          
          print("PITCH\t");  
          println(attitudePitch);
          
          print("YAW\t");  
          println(attitudeYaw);
                                  
        }  

        
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;  
    }   
    
    /**************************************************************/  
    else if (receiveDtype == dType_GyroBias)
    {                      
        if(debugMode == 1)
        {           
          println("");                                  
          println("- GyroBias");
          print("[ ");
          print(hex(droneGyroBias[0]));
          print(", ");
          print(hex(droneGyroBias[1]));
          print(", ");
          print(hex(droneGyroBias[2]));
          print(", ");
          print(hex(droneGyroBias[3]));
          print(", ");
          print(hex(droneGyroBias[4]));
          print(", ");
          print(hex(droneGyroBias[5]));        
          println(" ]");
          
          int GyroBias_Roll    = ((droneGyroBias[1] << 8) | (droneGyroBias[0]  & 0xff));
          int GyroBias_Pitch  = ((droneGyroBias[3] << 8) | (droneGyroBias[2]  & 0xff));
          int GyroBias_Yaw    = ((droneGyroBias[5] << 8) | (droneGyroBias[4]  & 0xff));
          
          print("GyroBias ROLL\t");  
          println(GyroBias_Roll);
          
          print("GyroBias PITCH\t");  
          println(GyroBias_Pitch);
          
          print("GyroBias YAW\t");  
          println(GyroBias_Yaw);
                                  
        }  
        
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;  
    }  
    
  /**************************************************************/  
    
    else if (receiveDtype == dType_TrimAll)
    {               
        if(debugMode == 1)
        {           
          println("");                                  
          println("- TrimAll");
          print("[ ");
          print(hex(droneTrimAll[0]));
          print(", ");
          print(hex(droneTrimAll[1]));
          print(", ");
          print(hex(droneTrimAll[2]));
          print(", ");
          print(hex(droneTrimAll[3]));
          print(", ");
          print(hex(droneTrimAll[4]));
          print(", ");
          print(hex(droneTrimAll[5]));        
          print(", ");
          print(hex(droneTrimAll[6]));        
          print(", ");
          print(hex(droneTrimAll[7]));        
          print(", ");
          print(hex(droneTrimAll[8]));      
          print(", ");
          print(hex(droneTrimAll[9]));        
          println(" ]");      
              
          int TrimAll_Roll      = ((droneTrimAll[1] << 8) | (droneTrimAll[0]  & 0xff));
          int TrimAll_Pitch      = ((droneTrimAll[3] << 8) | (droneTrimAll[2]  & 0xff));
          int TrimAll_Yaw        = ((droneTrimAll[5] << 8) | (droneTrimAll[4]  & 0xff));
          int TrimAll_Throttle  = ((droneTrimAll[7] << 8) | (droneTrimAll[6]  & 0xff));
          int TrimAll_Wheel      = ((droneTrimAll[9] << 8) | (droneTrimAll[8]  & 0xff));
                              
          print("Trim ROLL\t");  
          println(TrimAll_Roll);
          
          print("Trim PITCH\t");  
          println(TrimAll_Pitch);
          
          print("Trim YAW\t");  
          println(TrimAll_Yaw);
        
          print("Trim Throttle\t");  
          println(TrimAll_Throttle);
        
          print("Trim Wheel\t");  
          println(TrimAll_Wheel);
        }  

        
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;  
    }
  /**************************************************************/  
    else if (receiveDtype == dType_TrimFlight)    //
    {          
      if(debugMode == 1)
      {     
          println("");                                  
          println("- TrimFlight");
          print("[ ");
          print(hex(droneTrimFlight[0]));
          print(", ");
          print(hex(droneTrimFlight[1]));
          print(", ");
          print(hex(droneTrimFlight[2]));
          print(", ");
          print(hex(droneTrimFlight[3]));
          print(", ");
          print(hex(droneTrimFlight[4]));
          print(", ");
          print(hex(droneTrimFlight[5]));        
          print(", ");
          print(hex(droneTrimFlight[6]));        
          print(", ");
          print(hex(droneTrimFlight[7]));        
          println(" ]");      
            
          int TrimAll_Roll      = ((droneTrimFlight[1] << 8) | (droneTrimFlight[0]  & 0xff));
          int TrimAll_Pitch      = ((droneTrimFlight[3] << 8) | (droneTrimFlight[2]  & 0xff));
          int TrimAll_Yaw        = ((droneTrimFlight[5] << 8) | (droneTrimFlight[4]  & 0xff));
          int TrimAll_Throttle  = ((droneTrimFlight[7] << 8) | (droneTrimFlight[6]  & 0xff));
                          
          print("Trim ROLL\t");  
          println(TrimAll_Roll);
          
          print("Trim PITCH\t");  
          println(TrimAll_Pitch);
          
          print("Trim YAW\t");  
          println(TrimAll_Yaw);
        
          print("Trim Throttle\t");  
          println(TrimAll_Throttle);
        
       }  
        
        
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;  
      
      
    }    
              
    /**************************************************************/          
    else if (receiveDtype == dType_TrimDrive)    //
    {
            
        if(debugMode == 1)
        {   
          println("");                                  
          println("- TrimDrive");
          print("[ ");
          print(hex(droneTrimDrive[0]));
          print(", ");
          print(hex(droneTrimDrive[1]));
          println(" ]");
          
          int TrimAll_Wheel      = ((droneTrimDrive[1] << 8) | (droneTrimDrive[0]  & 0xff));
          
          print("Trim Wheel\t");  
          println(TrimAll_Wheel);
        }  
          
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;  
    }
    
    /**************************************************************/  
    else if(receiveDtype == dType_ImuRawAndAngle)
    {         
        if(debugMode == 1)
        {           
          println("");                                  
          println("- ImuRawAndAngle");
          print("[ ");
          print(hex(droneImuRawAndAngle[0]));
          print(", ");
          print(hex(droneImuRawAndAngle[1]));
          print(", ");
          print(hex(droneImuRawAndAngle[2]));
          print(", ");
          print(hex(droneImuRawAndAngle[3]));
          print(", ");
          print(hex(droneImuRawAndAngle[4]));
          print(", ");
          print(hex(droneImuRawAndAngle[5]));        
          print(", ");
          print(hex(droneImuRawAndAngle[6]));        
          print(", ");
          print(hex(droneImuRawAndAngle[7]));        
          print(", ");
          print(hex(droneImuRawAndAngle[8]));        
          println(" ]");
                    
          int ImuAccX  = droneImuRawAndAngle[0];
          int ImuAccY  = droneImuRawAndAngle[1];
          int ImuAccZ  = droneImuRawAndAngle[2];      
              
          int ImuGyroRoll    = droneImuRawAndAngle[3];
          int ImuGyroPitch  = droneImuRawAndAngle[4];
          int ImuGyroYaw    = droneImuRawAndAngle[5];  
                  
          int ImuAngleRoll  = droneImuRawAndAngle[6];
          int ImuAnglePitch  = droneImuRawAndAngle[7];
          int ImuAngleYaw    = droneImuRawAndAngle[8];
          
          
          print("AccX\t");  
          println(ImuAccX);
          
          print("AccY\t");  
          println(ImuAccY);
          
          print("AccZ\t");  
          println(ImuAccZ);
          
          
          print("GyroRoll\t");  
          println(ImuGyroRoll);
          
          print("GyroPitch\t");  
          println(ImuGyroPitch);
          
          print("GyroYaw \t");  
          println(ImuGyroYaw);
          
          
          print("AngleRoll\t");  
          println(ImuAngleRoll);
          
          print("AnglePitch\t");  
          println(ImuAnglePitch);
          
          print("AngleYaw\t");  
          println(ImuAngleYaw);
                        
        }  
            
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;  
    }
    
   /**************************************************************/    
    
    else if(receiveDtype == dType_Pressure)
    {         
        if(debugMode == 1)
        {             
          println("");                                  
          println("- Pressure");
          print("[ ");
          print(hex(dronePressure[0]));
          print(", ");
          print(hex(dronePressure[1]));
          print(", ");
          print(hex(dronePressure[2]));
          print(", ");
          print(hex(dronePressure[3]));
          println(" ]");
          
        }  
        
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;      
    }
    
    else if (receiveDtype ==  dType_ImageFlow)
     {
         
        if(debugMode == 1)
        {             
          println("");                                  
          println("- ImageFlow");
          print("[ ");
          print(hex(droneImageFlow[0]));
          print(", ");
          print(hex(droneImageFlow[1]));
          print(", ");
          print(hex(droneImageFlow[2]));
          print(", ");
          print(hex(droneImageFlow[3]));
          print(", ");
          print(hex(droneImageFlow[4]));
          print(", ");
          print(hex(droneImageFlow[5]));
          print(", ");
          print(hex(droneImageFlow[6]));          
          print(", ");
          print(hex(droneImageFlow[7]));
          println(" ]");
          
        }  
      
      receiveEventState = -1;    
      receiveComplete = -1;
      receiveLength = -1;
      receiveLinkState = -1;
      receiveDtype = -1;
    }
                
    else if (receiveDtype ==  dType_Button)
    {               
        if(debugMode == 1)
        {             
          println("");                                  
          println("- Button");
          print("[ ");
          print(hex(droneImageFlow[0]));
          println(" ]");
        }  
         
       receiveEventState = -1;    
      receiveComplete = -1;
      receiveLength = -1;
      receiveLinkState = -1;
      receiveDtype = -1;
    }
    
    else if (receiveDtype ==  dType_Batery)
    {        
        if(debugMode == 1)
        {             
          println("");                                  
          println("- Batery");
          print("[ ");
          print(hex(droneBattery[0]));
          print(", ");
          print(hex(droneBattery[1]));
          print(", ");
          print(hex(droneBattery[2]));
          print(", ");
          print(hex(droneBattery[3]));
          print(", ");
          print(hex(droneBattery[4]));
          print(", ");
          print(hex(droneBattery[5]));
          print(", ");
          print(hex(droneBattery[6]));
          print(", ");
          print(hex(droneBattery[7]));
          print(", ");
          print(hex(droneBattery[8]));
          print(", ");
          print(hex(droneBattery[9]));
          print(", ");
          print(hex(droneBattery[10]));
          print(", ");
          print(hex(droneBattery[11]));
          print(", ");
          print(hex(droneBattery[12]));
          print(", ");
          print(hex(droneBattery[13]));
          print(", ");
          print(hex(droneBattery[14]));
          print(", ");
          print(hex(droneBattery[15]));
                    
          println(" ]");
          
        }   
         
       receiveEventState = -1;    
      receiveComplete = -1;
      receiveLength = -1;
      receiveLinkState = -1;
      receiveDtype = -1;
    }
        
    else if (receiveDtype ==  dType_Motor)
    {        
        if(debugMode == 1)
        {             
          println("");                                  
          println("- Motor");
          print("[ ");
          print(hex(droneMotor[0]));
          print(", ");
          print(hex(droneMotor[1]));
          print(", ");
          print(hex(droneMotor[2]));
          print(", ");
          print(hex(droneMotor[3]));
          println(" ]");
        }  
           
       receiveEventState = -1;    
      receiveComplete = -1;
      receiveLength = -1;
      receiveLinkState = -1;
      receiveDtype = -1;
    }
    
    else if (receiveDtype == dType_Temperature)
    {         
        if(debugMode == 1)
        {             
          println("");                                  
          println("- Temperature");
          print("[ ");
          print(hex(droneTemperature[0]));
          print(", ");
          print(hex(droneTemperature[1]));
          print(", ");
          print(hex(droneTemperature[2]));
          print(", ");
          print(hex(droneTemperature[3]));
          print(", ");
          print(hex(droneTemperature[4]));
          print(", ");
          print(hex(droneTemperature[5]));
          print(", ");
          print(hex(droneTemperature[6]));
          print(", ");
          print(hex(droneTemperature[7]));                    
          println(" ]");
        }  
        
           
       receiveEventState = -1;    
      receiveComplete = -1;
      receiveLength = -1;
      receiveLinkState = -1;
      receiveDtype = -1;
    }
    
   /**************************************************************/    
                
    else if (receiveDtype == dType_LinkState)
    {                
        if(debugMode == 1)
        { 
          print(receiveLinkState);      
        }
        
        if(receiveLinkState == linkMode_None)  
        {      
          if(debugMode == 1)
          { 
            println(" : linkMode - None");  
          }
        }
        else if(receiveLinkState == linkMode_Boot)  
        {        
          if(debugMode == 1)
          { 
            println(" : linkMode - Boot");  
          }        
        }
        else if(receiveLinkState == linkMode_Ready)  
        {           
          if(debugMode == 1)
          { 
            println(" : linkMode - Ready");  
          }
        }
        else if(receiveLinkState == linkMode_Connecting)
        {                  
          if(debugMode == 1)
          { 
            println(" : linkMode - Connecting");  
          }
        }
        else if(receiveLinkState == linkMode_Connected)
        {        
          if(debugMode == 1)
          { 
            println(" : linkMode - Connected");
          }         
        }  
        else if(receiveLinkState == linkMode_Disconnecting)
        {        
          if(debugMode == 1)
          { 
            println(" : linkMode - Disconnecting");  
          }
        }
        else if(receiveLinkState == linkMode_ReadyToReset)  
        {      
          if(debugMode == 1)
          { 
            println(" : linkMode - ReadyToReset");    
          }        
        }

        linkState = receiveLinkState;
                  
        receiveEventState = -1;    
        receiveComplete = -1;
        receiveLength = -1;
        receiveLinkState = -1;
        receiveDtype = -1;
                  
    }    
  /**************************************************************/            
        
    else if ((receiveDtype == dType_LinkEvent) && (receiveEventState > 0))
    {    
              
      if(debugMode == 1)
      {             
          print(receiveEventState);
      }  
       
      if (receiveEventState == linkEvent_None)
      {       
        if(debugMode == 1)
        {             
           println(" : linkEvent - None");
        }      
      }  
        
      else if (receiveEventState == linkEvent_SystemReset)
      {        
        if(debugMode == 1)
        {             
           println(" : linkEvent - SystemReset");
        }  
      }
      
      else if (receiveEventState == linkEvent_Initialized)
      {        
        if(debugMode == 1)
        {             
           println(" : linkEvent - Initialized");
        }         
      }
      
      else if (receiveEventState == linkEvent_Scanning)
      {
        if(discoverFlag == 1) discoverFlag = 2;
        
        if(debugMode == 1)
        {     
         println(" : linkEvent - Scanning");
        }        
      }
      
      else if (receiveEventState == linkEvent_ScanStop)
      {
        if(discoverFlag == 2)
        {
          if(devCount > 0)
          {
           discoverFlag = 3;
          }
          else
          {
            discoverFlag = 4;
          }         
        }      
                
        if(debugMode == 1)
        {
          print("devCount : ");
          print(devCount);
          print(" ");
          print(discoverFlag);
          print(" ");          
           println(" : linkEvent - ScanStop");
        }  
      }
            
      else if (receiveEventState == linkEvent_FoundDroneService)
      {         
        if(debugMode == 1)
        {           
           println(" : linkEvent - FoundDroneService");
        }      
      }
      
      else if (receiveEventState == linkEvent_Connecting)
      {        
        if(debugMode == 1)
        {
           println(" : linkEvent - Connecting");
        }  
      }
      else if (receiveEventState == linkEvent_Connected)
      {        
        if(debugMode == 1)
        {
           println(" : linkEvent - Connected");
        }         
      }
      
      else if (receiveEventState == linkEvent_ConnectionFaild)
      {                        
        if(debugMode == 1)
        {
           println(" : linkEvent - ConnectionFaild");
        }   
      }
      
      else if (receiveEventState == linkEvent_ConnectionFaildNoDevices)
      {      
        if(debugMode == 1)
        {
         println(" : linkEvent - ConnectionFaildNoDevices");
        }  
      }
      
      else if (receiveEventState == linkEvent_ConnectionFaildNotReady)
      {      
        if(debugMode == 1)
        {
         println(" : linkEvent - ConnectionFaildNotReady");
        }  
      }
            
      else if (receiveEventState == linkEvent_PairingStart)
      {       
        if(debugMode == 1)
        {
         println(" : linkEvent - PairingStart");
        }       
      }
      
      else if (receiveEventState == linkEvent_PairingSuccess)
      {                
        if(debugMode == 1)
        {
         println(" : linkEvent - PairingSuccess");
        }              
      }
      else if (receiveEventState == linkEvent_PairingFaild)
      {                 
        if(debugMode == 1)
        {
           println(" : linkEvent - PairingFaild");
        }          
      }      
      
      else if (receiveEventState == linkEvent_BondingSuccess)
      {                
        if(debugMode == 1)
        {
         println(" : linkEvent - BondingSuccess");
        }       
      }      
      
      else if (receiveEventState == linkEvent_LookupAttribute)
      {                 
        if(debugMode == 1)
        {
         println(" : linkEvent - LookupAttribute");
        }  
      }      
      
      else if (receiveEventState == linkEvent_RssiPollingStart)
      {         
        if(debugMode == 1)
        {
         println(" : linkEvent - RssiPollingStart");
        }  
      }    
      else if (receiveEventState == linkEvent_RssiPollingStop)
      {                
        if(debugMode == 1)
        {
         println(" : linkEvent - RssiPollingStop");
        }  
      }      
      
      else if (receiveEventState == linkEvent_DiscoverService)
      {                
        if(debugMode == 1)
        {
         println(" : linkEvent - DiscoverService");
        }  
      }
      else if (receiveEventState == linkEvent_DiscoverCharacteristic)
      {       
        if(debugMode == 1)
        {
         println(" : linkEvent - DiscoverCharacteristic");
        }  
      }
      else if (receiveEventState == linkEvent_DiscoverCharacteristicDroneData)
      {        
        if(debugMode == 1)
        {
         println(" : linkEvent - DiscoverCharacteristicDroneData");
        }  
      }    
      else if (receiveEventState == linkEvent_DiscoverCharacteristicDroneConfig)
      {        
        if(debugMode == 1)
        {
         println(" : linkEvent - DiscoverCharacteristicDroneConfig");
        }  
      }
      else if (receiveEventState == linkEvent_DiscoverCharacteristicUnknown)
      {      
        if(debugMode == 1)
        {
         println(" : linkEvent - DiscoverCharacteristicUnknown");
        }  
      }
      else if (receiveEventState == linkEvent_DiscoverCCCD)
      {        
        if(debugMode == 1)
        {
         println(" : linkEvent - DiscoverCCCD");
        }        
      }
            
      else if (receiveEventState == linkEvent_ReadyToControl)
      {        
                
        if(debugMode == 1)
        {
         println(" : linkEvent - ReadyToControl");
        }         
        
        if(connectFlag == 1)
        {
          connectFlag = 0;         
                    
          /*            
          EEPROM.write(EEP_AddressCheck, 0x01);            
          for (int i = 0; i <= 5; i++)
          {
          //  devAddressConnected[i] = devAddressBuf[i];
            EEPROM.write(EEP_AddressFirst + i, devAddressBuf[i]);        
          }
          */
          for (int i = 0; i <= 5; i++)
          {
            devAddressConnected[i] = devAddressBuf[i];        
          }          
        }        
        //LED_Connect();
        pairing = true;    
        delay(500);
      }
          
      else if (receiveEventState == linkEvent_Disconnecting)
      {        
        if(debugMode == 1)
        {
           println(" : linkEvent - Disconnecting");
        }     
      }
      else if (receiveEventState == linkEvent_Disconnected)
      {        
        if(debugMode == 1)
        {
         println(" : linkEvent - Disconnected");
        }   
      }
      
      
      else if (receiveEventState == linkEvent_GapLinkParamUpdate)
      {        
        if(debugMode == 1)
        {
         println(" : linkEvent - GapLinkParamUpdate");
        }             
      }
   
      else if (receiveEventState == linkEvent_RspReadError)
      {        
        if(debugMode == 1)
        {
         println(" : linkEvent - RspReadError");
        }  
      }
      
      else if (receiveEventState == linkEvent_RspReadSuccess)
      {       
        if(debugMode == 1)
        {
         println(" : linkEvent - RspReadSuccess");
        }           
      }
      
      else if (receiveEventState == linkEvent_RspWriteError)
      {         
        if(debugMode == 1)
        {
         println(" : linkEvent - RspWriteError");
        }  
      }
      
      else if (receiveEventState == linkEvent_RspWriteSuccess)
      {
        if(sendCheckFlag == 1)
        {
          sendCheckFlag = 2;
        }
        
 
        if(debugMode == 1)
        {
         println(" : linkEvent - RspWriteSuccess");
        }  

      }
           
      else if (receiveEventState == linkEvent_SetNotify)
      {        
        if(debugMode == 1)
        {
         println(" : linkEvent - SetNotify");
        }  
      }
      
      else if (receiveEventState == linkEvent_Write)
      {  
        if(sendCheckFlag == 2)
        {
          sendCheckFlag = 3;
         }
            
        if(debugMode == 1)
        {
         println(" : linkEvent - Write");
        }  
      }  
      
      receiveEventState = -1;    
      receiveComplete = -1;
      receiveLength = -1;
      receiveLinkState = -1;
      receiveDtype = -1;  
    }          
  }  
  }
}