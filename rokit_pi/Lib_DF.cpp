//----------------------------------------------------------------------------
//    프로그램명   : Lib_DF 관련 함수
//
//    만든이		: 
//
//    날  짜		:
//    
//    최종 수정	:
//
//    MPU_Type	:
//
//    파일명		: Lib_DF.cpp
//----------------------------------------------------------------------------


#define HW_LIB_DF_LOCAL
#include "Lib_DF.h"


#include "./LIB/Define.h"
#include "./LIB/Uart_Lib.h"
#include "./LIB/Uart_Sig_Lib.h"
                                                                                                
#include "./LIB/Uart_Lib.c"
#include "./LIB/Uart_Sig_Lib.c"






//-- 내부 변수 
//

static bool IsOpened;


static int  UartHandle;




uint8_t cmdBuff[MAX_CMD_LENGTH];
uint8_t startBuff[2];
int cmdIndex = 0;
int checkHeader = 0;

bool SuccessReceive = false;
int team ;
int flightStatus;
int energy;
int battery;
int missileQuantity;


DF_OBJ DF_Value;


//-- 내부 함수
//
void DF_CmdRxd( char Data );






/*---------------------------------------------------------------------------
	TITLE : DF_Open
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
bool DF_Open( const char *pDevName )
{
	int i;


	IsOpened = false;



	//-- 시리얼 통신 초기화 
	UartHandle = Uart_Open( (char *)pDevName, BAUD_9600 );

	if( UartHandle < 0 )
	{
		printf("Uart Open Failed \n");
		return false;	
	}

	Uart_Sig_Init( UartHandle );
	Uart_Sig_Func_Init( UartHandle, DF_CmdRxd );


	IsOpened = true;


	return true;
}





/*---------------------------------------------------------------------------
	TITLE : DF_Update
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
bool DF_Update( void )
{
	bool Ret = false;




	return Ret;
}




/*---------------------------------------------------------------------------
	TITLE : DF_CmdRxd
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
void DF_CmdRxd( char Data )
{
	int input;
	int length;
	int type;
	int cs;
	int i;
	uint8_t checkSum;
	

	SuccessReceive = false;
 	team = -1;
 	flightStatus = -1;
 	energy = -1;
 	battery = -1;
 	missileQuantity  = -1;

	//printf("0x%X\n", Data);        	
	
	
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

        	//printf("Start\n");
      	}
      	else
      	{
        	if( checkHeader == 0 )
        	{
          		checkHeader = 0;
          		cmdIndex = 0;
        	}
      	}
    	/*
		if (cmdIndex == 2)
		{
			if ((cmdBuff[0] == 0x0A) && (cmdBuff[1] == 0x55))
        	{
          		checkHeader = 1;
        	}
        	else
        	{
          		checkHeader = 0;
          		cmdIndex = 0;
        	}
      	}
      	*/
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
	            	SuccessReceive = true;
	            
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

}




/*---------------------------------------------------------------------------
	TITLE : DF_SendPacket
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
void DF_SendPacket( int Roll, int Pitch, int Yaw, int Throttle, uint8_t EventData )
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
      


	Uart_Write( (char *)Packet, PACKET_LENGTH );        
}





/*---------------------------------------------------------------------------
	TITLE : DF_SendEvent
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
void DF_SendEvent( uint8_t EventData )
{
	DF_SendPacket( 0, 0, 0, 0, EventData );
}





/*---------------------------------------------------------------------------
	TITLE : DF_ReadStatus
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
DF_OBJ DF_ReadStatus( void )
{
	return DF_Value;
}




