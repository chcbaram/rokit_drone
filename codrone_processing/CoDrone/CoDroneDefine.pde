



byte START1            = 0x0A;
byte START2            = 0x55;
byte MAX_PACKET_LENGTH = 100;
byte SEND_CHECK_TIME   = 3;

byte NearbyDrone       = 1;
byte ConnectedDrone    = 2;
byte AddressInputDrone = 3;


byte linkMode_None               = byte(0); ///< 없음
byte linkMode_Boot               = byte(1); ///< 부팅      
byte linkMode_Ready              = byte(2); ///< 대기(연결 전)
byte linkMode_Connecting         = byte(3); ///< 장치 연결 중
byte linkMode_Connected          = byte(4); ///< 장치 연결 완료
byte linkMode_Disconnecting      = byte(5); ///< 장치 연결 해제 중
byte linkMode_ReadyToReset       = byte(6); ///< 리셋 대기(1초 뒤에 장치 리셋)  

  



byte LinkBroadcast_None          = byte(0); ///< 없음
byte LinkBroadcast_Mute          = byte(1); ///< LINK 모듈 데이터 송신 중단 . 아두이노 펌웨어 다운로드
byte LinkBroadcast_Active        = byte(2); ///< 페트론 연결 모드 . 모드 전환 메세지 전송
byte LinkBroadcast_Passive       = byte(3); ///< 페트론 연결 모드 . 모드 전환 메세지 전송하지 않음
byte LinkBroadcast_EndOfType     = byte(4);

  // 조종, 명령
byte dType_Control               = byte(0x10); ///< 조종
byte dType_Command               = byte(0x11); ///< 명령
byte dType_Command2              = byte(0x12); ///< 다중 명령(2가지 설정을 동시에 변경)
byte dType_Command3              = byte(0x13); ///< 다중 명령(3가지 설정을 동시에 변경)

  // 링크 보드
byte dType_LinkState             = byte(0xE0); ///< 링크 모듈의 상태
byte dType_LinkEvent             = byte(0xE1); ///< 링크 모듈의 이벤트
byte dType_LinkEventAddress      = byte(0xE2); ///< 링크 모듈의 이벤트 + 주소
byte dType_LinkRssi              = byte(0xE3); ///< 링크와 연결된 장치의 RSSI값
byte dType_LinkDiscoveredDevice  = byte(0xE4); ///< 검색된 장치
byte dType_LinkPasscode          = byte(0xE5); ///< 연결할 대상 장치의 암호 지정
byte dType_StringMessage         = byte(0xD0); ///< 문자열 메세지
  
  // 데이터 송수신  
byte dType_IrMessage             = byte(0x40); ///< IR 데이터 송수신
  
  // 상태
byte dType_Address               = byte(0x30); ///< IEEE address
byte dType_State                 = byte(0x31); ///< 드론의 상태(비행 모드, 방위기준, 배터리량)
byte dType_Attitude              = byte(0x32); ///< 드론의 자세(Vector)
byte dType_GyroBias              = byte(0x33); ///< 자이로 바이어스 값(Vector)
byte dType_TrimAll               = byte(0x34); ///< 전체 트림 (비행+주행)  
byte dType_TrimFlight            = byte(0x35); ///< 비행 트림
byte dType_TrimDrive             = byte(0x36); ///< 주행 트림
  
    // 센서
byte dType_ImuRawAndAngle        = byte(0x50); ///< IMU Raw + Angle
byte dType_Pressure              = byte(0x51); ///< 압력 센서 데이터
byte dType_ImageFlow             = byte(0x52); ///< ImageFlow
byte dType_Button                = byte(0x53); ///< 버튼 입력
byte dType_Batery                = byte(0x54); ///< 배터리
byte dType_Motor                 = byte(0x55); ///< 모터 제어 및 현재 제어 값 확인
byte dType_Temperature           = byte(0x56); ///< 온도
  
// 링크 보드
byte cType_LinkModeBroadcast    = byte(0xE0); ///< LINK 송수신 모드 전환
byte cType_LinkSystemReset      = byte(0xE1); ///< 시스템 재시작
byte cType_LinkDiscoverStart    = byte(0xE2); ///< 장치 검색 시작
byte cType_LinkDiscoverStop     = byte(0xE3); //< 장치 검색 중단
byte cType_LinkConnect          = byte(0xE4); ///< 연결
byte cType_LinkDisconnect       = byte(0xE5); ///< 연결 해제
byte cType_LinkRssiPollingStart = byte(0xE6); ///< RSSI 수집 시작
byte cType_LinkRssiPollingStop  = byte(0xE7); ///< RSSI 수집 중단

// 요청
byte cType_Request              = byte(0x90); ///< 지정한 타입의 데이터 요청





byte  dMode_None                = byte(0);    ///< 없음
byte  dMode_Flight              = byte(0x10); ///< 비행 모드(가드 포함)
byte  dMode_FlightNoGuard       = byte(0x11); ///< 비행 모드(가드 없음)
byte  dMode_FlightFPV           = byte(0x12); ///< 비행 모드(FPV)
byte  dMode_Drive               = byte(0x20); ///< 주행 모드
byte  dMode_DriveFPV            = byte(0x21); ///< 주행 모드(FPV)
byte  dMode_Test                = byte(0x30); ///< 테스트 모드


byte  vMode_None                = byte(0);
byte  vMode_Boot                = byte(1);    ///< 부팅
byte  vMode_Wait                = byte(2);    ///< 연결 대기 상태
byte  vMode_Ready               = byte(3);    ///< 대기 상태
byte  vMode_Running             = byte(4);    ///< 메인 코드 동작
byte  vMode_Update              = byte(5);    ///< 펌웨어 업데이트
byte  vMode_UpdateComplete      = byte(6);    ///< 펌웨어 업데이트 완료
byte  vMode_Error               = byte(7);    ///< 오류


byte  fMode_None                = byte(0);
byte  fMode_Ready               = byte(1);     ///< 비행 준비
byte  fMode_TakeOff             = byte(2);     ///< 이륙 (Flight로 자동전환)
byte  fMode_Flight              = byte(3);     ///< 비행
byte  fMode_Flip                = byte(4);     ///< 회전
byte  fMode_Stop                = byte(5);     ///< 강제 정지
byte  fMode_Landing             = byte(6);     ///< 착륙
byte  fMode_Reverse             = byte(7);     ///< 뒤집기
byte  fMode_Accident            = byte(8);     ///< 사고 (Ready로 자동전환)
byte  fMode_Error               = byte(9);     ///< 오류


byte  dvMode_None               = byte(0);
byte  dvMode_Ready              = byte(1);     ///< 준비
byte  dvMode_Start              = byte(2);     ///< 출발
byte  dvMode_Drive              = byte(3);     ///< 주행
byte  dvMode_Stop               = byte(4);     ///< 강제 정지
byte  dvMode_Accident           = byte(5);     ///< 사고 (Ready로 자동전환)
byte  dvMode_Error              = byte(6);     ///< 오류


byte  senOri_None               = byte(0);
byte  senOri_Normal             = byte(1);     ///< 정상
byte  senOri_ReverseStart       = byte(2);     ///< 뒤집히기 시작
byte  senOri_Reverse            = byte(3);     ///< 뒤집힘


byte  cSet_None                 = byte(0);     ///< 없음
byte  cSet_Absolute             = byte(1);     ///< 고정 좌표계
byte  cSet_Relative             = byte(2);     ///< 상대 좌표계



byte    linkEvent_None  = byte(0);                  ///< 없음
    
byte    linkEvent_SystemReset = byte(1);             ///< 시스템 리셋
    
byte    linkEvent_Initialized = byte(2);              ///< 장치 초기화 완료
    
byte    linkEvent_Scanning = byte(3);                 ///< 장치 검색 시작
byte    linkEvent_ScanStop = byte(4);                 ///< 장치 검색 중단

byte    linkEvent_FoundDroneService = byte(5);       ///< 드론 서비스 검색 완료

byte    linkEvent_Connecting = byte(6);                ///< 장치 연결 시작    
byte    linkEvent_Connected = byte(7);                ///< 장치 연결

byte    linkEvent_ConnectionFaild = byte(8);         ///< 연결 실패
byte    linkEvent_ConnectionFaildNoDevices = byte(9); ///< 연결 실패 - 장치가 없음
byte    linkEvent_ConnectionFaildNotReady = byte(10);  ///< 연결 실패 - 대기 상태가 아님

byte    linkEvent_PairingStart = byte(11);              ///< 페어링 시작
byte    linkEvent_PairingSuccess = byte(12);            ///< 페어링 성공
byte    linkEvent_PairingFaild = byte(13);              ///< 페어링 실패

byte    linkEvent_BondingSuccess = byte(14);            ///< Bonding 성공

byte    linkEvent_LookupAttribute = byte(15);          ///< 장치 서비스 및 속성 검색(GATT Event 실행)

byte    linkEvent_RssiPollingStart = byte(16);          ///< RSSI 풀링 시작
byte    linkEvent_RssiPollingStop = byte(17);          ///< RSSI 풀링 중지

byte    linkEvent_DiscoverService = byte(18);                    ///< 서비스 검색
byte    linkEvent_DiscoverCharacteristic = byte(19);              ///< 속성 검색
byte    linkEvent_DiscoverCharacteristicDroneData = byte(20);    ///< 속성 검색
byte    linkEvent_DiscoverCharacteristicDroneConfig = byte(21);  ///< 속성 검색
byte    linkEvent_DiscoverCharacteristicUnknown = byte(22);      ///< 속성 검색
byte    linkEvent_DiscoverCCCD = byte(23);        ///< CCCD 검색

byte    linkEvent_ReadyToControl = byte(24);      ///< 제어 준비 완료

byte    linkEvent_Disconnecting = byte(25);      ///< 장치 연결 해제 시작
byte    linkEvent_Disconnected = byte(26);        ///< 장치 연결 해제 완료

byte    linkEvent_GapLinkParamUpdate = byte(27);  ///< GAP_LINK_PARAM_UPDATE_EVENT

byte    linkEvent_RspReadError = byte(28);        ///< RSP 읽기 오류
byte    linkEvent_RspReadSuccess = byte(29);      ///< RSP 읽기 성공

byte    linkEvent_RspWriteError = byte(30);      ///< RSP 쓰기 오류
byte    linkEvent_RspWriteSuccess = byte(31);    ///< RSP 쓰기 성공

byte    linkEvent_SetNotify = byte(32);          ///< Notify 활성화

byte    linkEvent_Write = byte(33);              ///< 데이터 쓰기 이벤트





  // 상태
byte  Req_Address = byte(0x30);         ///< IEEE address
byte  Req_State = byte(0x31);                  ///< 드론의 상태(비행 모드, 방위기준, 배터리량)
byte  Req_Attitude = byte(0x32);               ///< 드론의 자세(Vector)
byte  Req_GyroBias = byte(0x33);               ///< 자이로 바이어스 값(Vector)
byte  Req_TrimAll = byte(0x34);                 ///< 전체 트림
byte  Req_TrimFlight = byte(0x35);             ///< 비행 트림
byte  Req_TrimDrive = byte(0x36);               ///< 주행 트림
    
  // 센서
byte  Req_ImuRawAndAngle = byte(0x50);   ///< IMU Raw + Angle
byte  Req_Pressure = byte(0x51);               ///< 압력 센서 데이터
byte  Req_ImageFlow = byte(0x52);               ///< ImageFlow
byte  Req_Button = byte(0x53);                 ///< 버튼 입력
byte  Req_Batery = byte(0x54);                 ///< 배터리
byte  Req_Motor = byte(0x55);                   ///< 모터 제어 및 현재 제어 값 확인
byte  Req_Temperature = byte(0x56);             ///< 온도
 