//----------------------------------------------------------------------------
//    프로그램명   : DF 관련 헤더
//
//    만든이		: 
//
//    날  짜		:
//    
//    최종 수정	:
//
//    MPU_Type	:
//
//    파일명		: DF.h
//----------------------------------------------------------------------------

                                                                                                  
#ifndef __DF_H__
#define __DF_H__


 
 
#include <inttypes.h>
#include <Arduino.h> 



#define DF_SERIAL				Serial1



//START CODE
#define START1          		0x0A
#define START2          		0x55

//HEADER TYPE
#define CONTROL          		0x20
#define STATE            		0x21

#define LENGTH           		0x05

//EVENT
#define  NONE					0x00
#define  MISSILE				0x10
#define  SHIELD					0x11
#define  DEMON					0x12
#define  WATERBOMB				0x13
#define  BOOSTER				0x14
#define  HEADINGLOCK			0x15

#define  TRIM_RESET				0x80
#define  TRIM_PITCH_INCREASE	0x81
#define  TRIM_PITCH_DECREASE	0x82
#define  TRIM_YAW_INCREASE		0x83
#define  TRIM_YAW_DECREASE		0x84
#define  TRIM_ROLL_INCREASE		0x85
#define  TRIM_ROLL_DECREASE		0x86

#define  TAKE_OFF				0xA0
#define  STOP					0xA1  //Landing

#define  GYROBIAS				0xB0
#define  RESET_YAW				0xB1
#define  PAIRING				0xB2

#define  TEAM_RED				0xC0
#define  TEAM_BLUE				0xC1

#define  LEVEL_BEGINNER			0xD0
#define  LEVEL_EXPERT			0xD1

#define  ABSOLUTE				0xE0
#define  RC						0xE1

#define  OFF					0x00
#define  ON						0x01
	
	
#define READY					0x00
#define FLY						0x01
#define TRIM					0x02

#define DOWN                    0x00
#define UP                      0x01


#define PACKET_LENGTH 			10
#define MAX_CMD_LENGTH 			11



typedef struct 
{
	uint8_t	Flight;
	uint8_t	Energy;
	uint8_t	Battery;
	uint8_t	MissileQuantity;

} DF_OBJ;



class cDF
{
public:
	cDF();

	bool begin( void );

	bool   update( void );
	bool   ProcessRxd( char Data );
	void   SendEvent( uint8_t EventData );
	void   SendPacket( int Roll, int Pitch, int Yaw, int Throttle, uint8_t EventData );
	DF_OBJ ReadStatus( void );

	uint8_t GetFlight() { return DF_Value.Flight; };
	uint8_t GetEnergy() { return DF_Value.Energy; };
	uint8_t GetBattery() { return DF_Value.Battery; };
	uint8_t GetMissileQuantity() { return DF_Value.MissileQuantity; };

public:
	bool IsOpened;
	bool bConnected;

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
};

 

#endif