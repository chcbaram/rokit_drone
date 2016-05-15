/*
	Cupdrone Remote

	Made by Baram ( chcbaram@paran.com )
*/
#include <EEPROM.h>
#include "MSP_Cmd.h"
#include "MSP.h"
#include "BLE.h"
#include "JOY.h"
#include "DF.h"
#include "U8glib.h"
	


#define JOY_IN_THRUST        A0
#define JOY_IN_ROLL          A1
#define JOY_IN_PITCH         A2	
#define JOY_IN_YAW           A3


// Button
#define KEY_UP     			4
#define KEY_DOWN   			5
#define KEY_LEFT   			6
#define KEY_RIGHT  			8
#define KEY_ENTER  			7


#define STATE_MAIN_MENU		0
#define STATE_RUN_MENU		1
#define STATE_REMOTE		3


#define MENU_REMOTE			0
#define MENU_SAVE			1



int16_t Roll   = 0;
int16_t Pitch  = 0;
int16_t Yaw    = 0;
int16_t Thrust = 0;

int joy_roll 	= 0;
int joy_pitch 	= 0;
int joy_yaw 	= 0;
int joy_thrust 	= 0;


U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_DEV_0 |  U8G_I2C_OPT_NO_ACK | U8G_I2C_OPT_FAST);


cDF		DF;
JOY     JoyL;
JOY     JoyR;

uint8_t main_state = 0;
uint8_t fly_mode = 0;



#define MENU_ITEMS 2
char *menu_strings[MENU_ITEMS] = { "Remote", "Save" };

uint8_t menu_current = 0;
uint8_t menu_redraw_required = 0;

uint32_t tTime_Msp;  







void setup() 
{
	int ret;

	//-- 사용되는 버튼 설정
	//
	pinMode(KEY_UP, INPUT);           	// set pin to input
	pinMode(KEY_DOWN, INPUT);           // set pin to input
	pinMode(KEY_LEFT, INPUT);         	// set pin to input
	pinMode(KEY_RIGHT, INPUT);         	// set pin to input
	pinMode(KEY_ENTER, INPUT);         	// set pin to input

	digitalWrite(KEY_UP, HIGH);       	// turn on pullup resistors
	digitalWrite(KEY_DOWN, HIGH);       // turn on pullup resistors
	digitalWrite(KEY_LEFT, HIGH);       // turn on pullup resistors
	digitalWrite(KEY_RIGHT, HIGH);     	// turn on pullup resistors
	digitalWrite(KEY_ENTER, HIGH);     	// turn on pullup resistors

	//-- LCD 라이브러리 설정
	//
	u8g.setFont(u8g_font_6x13);
	u8g.setFontPosTop();
	u8g.setColorIndex(1);

	DF.begin();

	JoyL.begin(A2, A3, 5);
	JoyR.begin(A0, A1, 5);
	JoyL.set_dir( -1, -1 );
	JoyR.set_dir( -1, -1 );


	menu_redraw_required = 1;


	lcd_draw_str( 0, 0, "Remote For Rokit" );
	delay(1500);
}





void loop() 
{
	static uint32_t tTime;  
	static uint32_t i = 0;  


	tTime = millis();
	loop_main();
	tTime_Msp = millis()-tTime;
	
	loop_joystick();
	loop_df();
}





bool key_get_button( int pin )
{
	bool ret = false;


	if( digitalRead(pin) == LOW )
	{
		delay(70);
		if( digitalRead(pin) == LOW )
		{
			while( digitalRead(pin) == LOW );
			ret = true;
		}					
	}

	return ret;
}





void loop_main()
{
	uint8_t err_code;
	char Str[24];
	static uint32_t tTime;  


	switch( main_state )
	{
		case STATE_MAIN_MENU:
			lcd_draw_menu();

			if( key_get_button(KEY_DOWN) == true )
			{
				menu_current++;	
				menu_current %= MENU_ITEMS;
				menu_redraw_required = 1;
			}
			if( key_get_button(KEY_UP) == true )
			{
				menu_current--;	
				menu_current %= MENU_ITEMS;
				menu_redraw_required = 1;
			}
			if( key_get_button(KEY_ENTER) == true )
			{
				main_state = STATE_RUN_MENU;
			}
			break;

		case STATE_RUN_MENU:
			main_state = run_menu( menu_current );
			menu_redraw_required = 1;
			break;

	
		case STATE_REMOTE:
			if( (millis()-tTime) > 500 )
			{
				menu_redraw_required = 1;
				tTime = millis();
			}
			lcd_draw_remote();
			
			if( key_get_button(KEY_ENTER) == true )
			{
				main_state = STATE_MAIN_MENU;
				menu_redraw_required = 1;
			}		

			if( key_get_button(KEY_RIGHT) == true )
			{
				if( DF.IsOpened == true )
				{
					DF.SendEvent( STOP );
					fly_mode = 0;
				}
			}	

			if( key_get_button(KEY_LEFT) == true )
			{
				if( DF.IsOpened == true )
				{
					DF.SendEvent( RESET_YAW );
					fly_mode = 1;
				}
			}	

			if( key_get_button(KEY_UP) == true )
			{
				//if( Msp.bConnected == true )
				{
				//	Msp.SendCmd_DISARM();
				}
			}	
			break;

		case 0xFF:
			break;
	}
}


uint8_t run_menu( int menu_sel )
{
	char Str[24];
	char StrConv[24];
	String strRet;
	uint8_t err_code;
	uint8_t i;
	uint8_t ret_state = STATE_MAIN_MENU;


	switch( menu_sel )
	{
		case MENU_REMOTE:
			//lcd_draw_str( 0, 0, "Remote..." );
			//delay(1000);		
			ret_state = STATE_REMOTE;
			break;

		case MENU_SAVE:
			lcd_draw_str( 0, 0, "Saving..." ); 

			/*
			if( Ble.BleList.Count == 0 )
			{
				lcd_draw_str( 0, 0, "Saving..No Data" );
			}
			else
			{	
				Ble.save_list();
				lcd_draw_str( 0, 0, "Saving..OK" );
			}
			*/
			delay(1000);		
			break;
	}

	return ret_state;
}



void loop_df() 
{
	static uint32_t tTime;  
	static uint32_t i = 0;  


	if( DF.IsOpened == true )
	{
		if( DF.update() == true )
		{
			/*
			Serial.print(DF.GetFlight());
			Serial.print(" ");
			Serial.print(DF.GetEnergy());
			Serial.print(" ");
			Serial.print(DF.GetBattery());
			Serial.print(" ");
			Serial.print(DF.GetMissileQuantity());
			Serial.println(" ");
			*/

		}

		if( (millis()-tTime) > 50 )
		{
			
			if( fly_mode == 1 )
				DF.SendPacket( Roll, Pitch, Yaw, Thrust, 0x00 );	
			else
				DF.SendPacket( Roll, Pitch, Yaw, Thrust, STOP );	
			

			tTime = millis();
		}
	}
}





void loop_joystick()
{
	static uint32_t tTime;



		// -500~500
		joy_thrust = map( JoyR.get_pitch(), -500, 500,  -100, 100 );


		// Left/Right(-500~500)
		joy_roll = map( JoyL.get_roll(), -500, 500,  -100, 100 );

		// Up/Down(500~-500)
		joy_pitch = map( JoyL.get_pitch(), -500, 500, -100, 100 );

		// Left/Right(500~-500)
		joy_yaw = map( JoyR.get_roll(), -500, 500, -100, 100 );



		if( DF.IsOpened == true )
		{
			Roll   = joy_roll;
			Pitch  = joy_pitch;
			Yaw    = joy_yaw;

			Thrust = joy_thrust;			
		}
		else
		{
			Roll   = 0;
			Pitch  = 0;
			Yaw    = 0;
			Thrust = 0;
		}
}





void lcd_draw_menu( void )
{
	uint8_t i, h;
	u8g_uint_t w, d;
	static uint32_t tTime;

	if( menu_redraw_required == 0 ) return;

	u8g.firstPage();  
  	do 
  	{
		//u8g.setFont(u8g_font_6x13);
		u8g.setFontRefHeightText();
		u8g.setFontPosTop();

		h = u8g.getFontAscent()-u8g.getFontDescent();
		w = u8g.getWidth();
		for( i = 0; i < MENU_ITEMS; i++ ) 
		{
			d = (w-u8g.getStrWidth(menu_strings[i]))/2;
			u8g.setDefaultForegroundColor();
			if ( i == menu_current ) 
			{
				u8g.drawBox(0, i*h+1, w, h);
      			u8g.setDefaultBackgroundColor();
			}
			u8g.drawStr(d, i*h, menu_strings[i]);
		}

  	} while( u8g.nextPage() );

  	u8g.setDefaultForegroundColor();

  	menu_redraw_required = 0;
}



void lcd_draw_str( int x, int y, char *pStr )
{
	uint8_t i, h;
	u8g_uint_t w, d;
	

	h = u8g.getFontAscent()-u8g.getFontDescent();
	w = u8g.getWidth();

	u8g.firstPage();  
  	do 
  	{
		u8g.drawStr( w*x, y*h+1, pStr);
  	} while( u8g.nextPage() );
}



void lcd_draw_remote( void )
{
	uint8_t i, h;
	u8g_uint_t w, d;
	static uint32_t tTime;
	String strRet;
	char Str[32];


	if( menu_redraw_required == 0 ) return;

	h = u8g.getFontAscent()-u8g.getFontDescent();
	w = u8g.getWidth();

	u8g.firstPage();  
  	do 
  	{
		sprintf(Str, "L : %d, %d", JoyL.get_roll(), JoyL.get_pitch());
		u8g.drawStr( 0*w, 0*h+1, Str);

		//sprintf(Str, "LP : %d", JoyL.get_pitch());
		//u8g.drawStr( 0*w, 1*h+1, Str);

		sprintf(Str, "R : %d, %d", JoyR.get_roll(), JoyR.get_pitch());
		u8g.drawStr( 0*w, 1*h+1, Str);

		//sprintf(Str, "RP : %d", JoyR.get_pitch());
		//u8g.drawStr( 0*w, 3*h+1, Str);
		sprintf(Str, "RP : %d, %d", joy_roll, joy_pitch);
		u8g.drawStr( 0*w, 2*h+1, Str);
		sprintf(Str, "TR : %d", Thrust);
		u8g.drawStr( 0*w, 3*h+1, Str);


		sprintf(Str, "D:%d, ", DF.bConnected );
		u8g.drawStr( 0*w, 4*h+1, Str);

	

  	} while( u8g.nextPage() );

  	menu_redraw_required = 0;
}

