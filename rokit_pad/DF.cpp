//----------------------------------------------------------------------------
//    프로그램명   : DroneFighter 관련 함수
//
//    만든이		: 
//
//    날  짜		:
//    
//    최종 수정	:
//
//    MPU_Type	:
//
//    파일명		: DF.cpp
//----------------------------------------------------------------------------



#include "DF.h"

#include <Arduino.h> 









cDF::cDF()
{
	IsOpened		= false;
	bConnected		= false;
	cmdIndex 		= 0;
	checkHeader 	= 0;
	SuccessReceive 	= false;
}



/*---------------------------------------------------------------------------
	TITLE : begin
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
bool cDF::begin( void )
{
	int i;


	IsOpened = false;

	DF_SERIAL.begin(9600);

	IsOpened = true;

	return true;
}





/*---------------------------------------------------------------------------
	TITLE : update
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
bool cDF::update( void )
{
	bool Ret = false;
	char ch;


	//-- 명령어 수신
	//
	if( DF_SERIAL.available() )
	{
		ch = DF_SERIAL.read();

	}
	else
	{
		return false;
	}


	Ret = ProcessRxd( ch );

	return Ret;
}




/*---------------------------------------------------------------------------
	TITLE : ProcessRxd
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
bool cDF::ProcessRxd( char Data )
{
	int input;
	int length;
	int type;
	int cs;
	int i;
	uint8_t checkSum;
	bool ret = false;
	static uint32_t tTime;

	SuccessReceive = false;
 	team = -1;
 	flightStatus = -1;
 	energy = -1;
 	battery = -1;
 	missileQuantity  = -1;

	//printf("0x%X\n", Data);        	
	

	//-- 바이트간 타임아웃 설정(500ms)
	//
	if( (micros() - tTime) > 1000000 )
	{
		checkHeader = 0;
		cmdIndex    = 0;
		tTime = micros();
		bConnected = false;
	}	


	
    cmdBuff[cmdIndex++] = Data;
    
    startBuff[0] = startBuff[1];
    startBuff[1] = Data;

    if (cmdIndex >= MAX_CMD_LENGTH)
    {
    	checkHeader = 0;
		cmdIndex = 0;
    }
    else
    {
		if ((startBuff[0] == 0x0A) && (startBuff[1] == 0x55) && (checkHeader == 0) )
      	{
        	checkHeader = 1;
        	cmdIndex = 2;
        	cmdBuff[0] = startBuff[0];
        	cmdBuff[1] = startBuff[1]; 
      	}
      	else
      	{
        	if( checkHeader == 0 )
        	{
          		checkHeader = 0;
          		cmdIndex = 0;
        	}
      	}
      	if (checkHeader == 1)
      	{
        	if (cmdIndex == 3)
        	{
	          	if (cmdBuff[2] == 0x21)
	          	{
		            type = cmdBuff[2];
	    	        checkHeader = 2;
	          	}	
	          	else
	          	{
	            	checkHeader = 0;
	            	cmdIndex = 0;
	          	}
	        }
		}

		if (checkHeader == 2)
      	{
	        if (cmdIndex == 4)
    	    {
          		length = cmdBuff[3];
        	}
        	else if (cmdIndex == 10)
        	{
          		cs = cmdBuff[9];

	          	checkSum = 0;
	          	for (i = 2; i < 9; i++)
	          	{
	            	checkSum += cmdBuff[i];
	          	}
	          
	          	if (cs == checkSum)
	          	{
	          		ret = true;
	            	SuccessReceive = true;
	            	bConnected     = true;
	            
	            	team = cmdBuff[4];
	            	flightStatus = cmdBuff[5];
	            	energy = cmdBuff[6];
	            	battery = cmdBuff[7];
	            	missileQuantity = cmdBuff[8];       

					//printf("Rxd %d %d %d %d\n", flightStatus, energy, battery, missileQuantity );	            	
					DF_Value.Flight  = flightStatus;
					DF_Value.Energy  = energy;
					DF_Value.Battery = battery;
					DF_Value.MissileQuantity = missileQuantity;
	          	}
	   
	          	checkHeader = 0;
	          	cmdIndex = 0;
	        }
      	}
    }

    return ret;
}




/*---------------------------------------------------------------------------
	TITLE : SendPacket
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
void cDF::SendPacket( int Roll, int Pitch, int Yaw, int Throttle, uint8_t EventData )
{
    volatile uint8_t Packet[10];
    volatile uint8_t CheckSum;
    int i;


    // Start
    Packet[0] = 0x0A;
    Packet[1] = 0x55;
    
    // Header
    Packet[2] = 0x20;
    Packet[3] = 0x05;
    
    Packet[4] = Roll;
    Packet[5] = Pitch;
    Packet[6] = Yaw;
    Packet[7] = Throttle;
    Packet[8] = EventData;
    
    CheckSum = 0;
    for( i=2; i<9; i++ )
    {
      CheckSum = (CheckSum + Packet[i]);  
    }
    Packet[9] = CheckSum;
      

    for( i=0; i<PACKET_LENGTH; i++ )
    {
    	DF_SERIAL.write( Packet[i] );
    }
}





/*---------------------------------------------------------------------------
	TITLE : SendEvent
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
void cDF::SendEvent( uint8_t EventData )
{
	SendPacket( 0, 0, 0, 0, EventData );
}





/*---------------------------------------------------------------------------
	TITLE : ReadStatus
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
DF_OBJ cDF::ReadStatus( void )
{
	return DF_Value;
}




