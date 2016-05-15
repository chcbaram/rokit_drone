#include "main.h"
#include "Lib_Joy.h"    
#include "Lib_DF.h"


#include <time.h>








void show( void );
void run( char *pUartPort );

unsigned long mills( void );



//-- main
//
int main(int argc, char **argv)
{
	bool Ret;


	Ret = Joy_Open("/dev/input/js0");

	if( Ret == false )
	{
		printf("Joy_Open Fail\n");
		return -1;
	}

	if( argc < 2 )
	{
		printf("Option \n");
        printf(" show \n");            
        printf(" run \n");            
	}
	else
	{
		if( strcmp(argv[1], "show") == 0 )
		{
			show();
		}
		else
		if( strcmp(argv[1], "run") == 0 )
		{
			if( argc < 3 )
			{
				printf("Add Uart Port..\n");
				return -1;
			}
			else
			{
				run( argv[2] );
			}
		}
		
	}
    


	return 0;
}


void delay(int delay_ms)
{
    unsigned long ms = delay_ms;


    usleep(ms*1000);
}


unsigned long mills( void )
{
    struct timeval ts;

    gettimeofday(&ts, NULL);
    return ( ts.tv_sec * 1000 + ts.tv_usec / 1000L );
}



/*---------------------------------------------------------------------------
	TITLE : show
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
void show( void )
{
	bool Ret;
	JOY_OBJ Joy;

	while(1)
	{
		Ret = Joy_Update();


		if( Ret == true )
		{
			Joy = Joy_Read();

			printf("Event: type %d, time %d, number %d, value %d\n", Joy.js_type, Joy.js_time, Joy.js_number, Joy.js_value);
		}

	}	
}










/*---------------------------------------------------------------------------
	TITLE : show
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
void run( char *pUartPort )
{
	bool Ret;
	JOY_OBJ Joy;
	unsigned long tTime;
	unsigned long tTimeSend;
	bool Fly = false;
	DF_OBJ DF_Ret;

	Ret = DF_Open( pUartPort );

	if( Ret == false )
	{
		printf("DF_Open Fail\n");
		return;
	}
	else
	{
		printf("DF_Open : %s\n", pUartPort);
	}

	while(1)
	{
		Ret = Joy_Update();

		if( Ret == true )
		{
			Joy = Joy_Read();

			//printf("Run: type %d, time %d, number %d, value %d\n", Joy.js_type, Joy.js_time, Joy.js_number, Joy.js_value);
			//printf("Axis %d, %d \n", Joy.AxisValue[0], Joy.AxisValue[1] );
			//printf("Axis %f, %f, %f, %f \n", Joy.fRoll, Joy.fPitch, Joy.fYaw, Joy.fThrutle );

			if( Joy.ButtonValue[0] == true )
			{
				DF_SendEvent( RESET_YAW );
				printf("RESET_YAW\n");
				Fly = true;
			}

			if( Joy.ButtonValue[1] == true )
			{
				DF_SendEvent( STOP );
				printf("STOP\n");
				Fly = false;
			}			

			if( Joy.ButtonValue[2] == true )
			{
				DF_SendEvent( ABSOLUTE );
				printf("AB MODE\n");
				Fly = false;
			}			

			if( Joy.ButtonValue[3] == true )
			{
				DF_SendEvent( RC );
				printf("RC MODE\n");
				Fly = false;
			}			

		}

		if( (mills() - tTime) > 1000 )
		{
			tTime = mills();
			DF_Ret = DF_ReadStatus();

			printf("Fly:%d, Battery:%d \n", DF_Ret.Flight, DF_Ret.Battery);			
		}

		if( (mills() - tTimeSend) > 100 )
		{
			tTimeSend = mills();

			if( Fly == true )
				DF_SendPacket( Joy.fRoll*100, Joy.fPitch*100, Joy.fYaw*100, Joy.fThrutle*100, 0x00 );	
			else
				DF_SendPacket( Joy.fRoll*100, Joy.fPitch*100, Joy.fYaw*100, Joy.fThrutle*100, STOP );	
		}
	}		
}

