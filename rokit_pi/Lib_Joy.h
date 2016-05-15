//----------------------------------------------------------------------------
//    프로그램명   : Lib_Joy 관련 헤더
//
//    만든이		: 
//
//    날  짜		:
//    
//    최종 수정	:
//
//    MPU_Type	:
//
//    파일명		: Lib_Joy.h
//----------------------------------------------------------------------------

                                                                                                  
#ifndef __LIB_JOY_H__
#define __LIB_JOY_H__


#ifdef   LIB_JOY_LOCAL
#define  EXT_LIB_JOY_DEF
#else
#define  EXT_LIB_JOY_DEF     extern
#endif
 
 
#include <stdio.h>
#include <errno.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <signal.h>
#include <linux/joystick.h>
#include <stdint.h>



typedef struct 
{

	uint8_t AxisCnt;
	uint8_t ButtonCnt;
	int     Version;
	char    Name[128];

	uint8_t  js_type;
	uint32_t js_time;
	uint8_t  js_number;
	int16_t  js_value;

	int16_t  AxisValue[128];
	int16_t  ButtonValue[128];
	bool     ButtonEvent[128];

	float    fRoll;
	float    fPitch;
	float    fYaw;
	float    fThrutle;
} JOY_OBJ;



EXT_LIB_JOY_DEF bool Joy_Open( const char *pDevName );
EXT_LIB_JOY_DEF bool Joy_Update( void );

EXT_LIB_JOY_DEF JOY_OBJ Joy_Read( void );

#endif