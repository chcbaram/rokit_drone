//----------------------------------------------------------------------------
//    프로그램명   : Lib_Joy 관련 함수
//
//    만든이		: 
//
//    날  짜		:
//    
//    최종 수정	:
//
//    MPU_Type	:
//
//    파일명		: Lib_Joy.cpp
//----------------------------------------------------------------------------


#define HW_LIB_JOY_LOCAL
#include "Lib_Joy.h"





#define NAME_LENGTH 128


#define JOY_ROLL		0
#define JOY_PITCH		1
#define JOY_YAW			2
#define JOY_THRUTLE		5



//-- 내부 변수 
//

static bool IsOpened;


static int fd;


JOY_OBJ	Joy_Value;


//-- 내부 함수
//



/*---------------------------------------------------------------------------
	TITLE : Joy_Init
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
bool Joy_Open(  const char *pDevName )
{
	int i;


	IsOpened = false;


	Joy_Value.AxisCnt   = 0;
	Joy_Value.ButtonCnt = 0;
	Joy_Value.Version   = 0x0000;	
	strcpy( Joy_Value.Name, "Unknown" );


	Joy_Value.fRoll    = 0.0f;
	Joy_Value.fPitch   = 0.0f;
	Joy_Value.fYaw     = 0.0f;
	Joy_Value.fThrutle = 0.0f;


	for( i=0; i<128; i++ )
	{
		Joy_Value.AxisValue[i]   = 0;
		Joy_Value.ButtonValue[i] = 0;
		Joy_Value.ButtonEvent[i] = false;
	}


	if ((fd = open(pDevName, O_RDONLY)) < 0) 
	{
		perror("open_fail");
		//exit(1);
		return false;
	}


	ioctl(fd, JSIOCGVERSION, &Joy_Value.Version);
	ioctl(fd, JSIOCGAXES, &Joy_Value.AxisCnt);
	ioctl(fd, JSIOCGBUTTONS, &Joy_Value.ButtonCnt);
	ioctl(fd, JSIOCGNAME(NAME_LENGTH), Joy_Value.Name);
	fcntl(fd, F_SETFL, O_NONBLOCK);

	printf("Joystick (%s) has %d axes and %d buttons. Driver version is %d.%d.%d.\n",
		Joy_Value.Name, Joy_Value.AxisCnt, Joy_Value.ButtonCnt, Joy_Value.Version >> 16, (Joy_Value.Version >> 8) & 0xff, Joy_Value.Version & 0xff);
	

	IsOpened = true;

	return true;
}





/*---------------------------------------------------------------------------
	TITLE : Joy_Update
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
bool Joy_Update( void )
{
	bool ret = false;
	int i;
	struct js_event js;	


	if( read(fd, &js, sizeof(struct js_event)) == sizeof(struct js_event))  
	{
		//printf("Event: type %d, time %d, number %d, value %d\n", js.type, js.time, js.number, js.value);



		switch( js.type & ~JS_EVENT_INIT ) 
		{
			case JS_EVENT_BUTTON:
				if( Joy_Value.ButtonValue[js.number] != js.value )
				{
					Joy_Value.ButtonEvent[js.number] = true;		
				}
				Joy_Value.ButtonValue[js.number] = js.value;
				break;

			case JS_EVENT_AXIS:
				Joy_Value.AxisValue[js.number] = js.value;

				if( js.number == JOY_ROLL    ) Joy_Value.fRoll    =  (float)js.value / 32767.0f;
				if( js.number == JOY_PITCH   ) Joy_Value.fPitch   = -(float)js.value / 32767.0f;
				if( js.number == JOY_YAW     ) Joy_Value.fYaw     =  (float)js.value / 32767.0f;				
				if( js.number == JOY_THRUTLE ) Joy_Value.fThrutle = -(float)js.value / 32767.0f;				
				break;
		}

		Joy_Value.js_type   = js.type;
		Joy_Value.js_time   = js.time;
		Joy_Value.js_number = js.number;
		Joy_Value.js_value  = js.value;



		ret = true;
	}


	return ret;
}





/*---------------------------------------------------------------------------
	TITLE : Joy_Read
	WORK  :
	ARG   : void
	RET   : void
---------------------------------------------------------------------------*/
JOY_OBJ Joy_Read( void )
{
	JOY_OBJ	JoyRet;
	int i;

	JoyRet = Joy_Value;


	for( i=0; i<128; i++ )
	{
		Joy_Value.ButtonEvent[i] = false;
	}

	return JoyRet;
}

