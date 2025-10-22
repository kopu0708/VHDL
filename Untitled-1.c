#include <avr/io.h>
#include <util/delay.h>
unsigned char segment[] = {0x3F, 0x06, 0x5B, 0x4F, 0x6D, 0x40} // 0,1, 2, 3, S, - 순서

void display_fnd(unsigned char display_data[])
{    for(int i = 0; i < 4; i++) // 4개 자리를 순환
    {
        PORTA = 0x00;         // (고스트 현상 방지)
        PORTF = (1 << i);     // 0001(Q0), 0010(Q1), 0100(Q2), 1000(Q3)
        PORTA = display_data[i]; // 해당 자리에 맞는 세그먼트 켜기
        _delay_ms(1);         // 1ms 딜레이 (잔상 효과)
    }
}

int main(void) {
	DDRA = 0xff; //PA0 – PA7 (segment)출력
	DDRB = 0xff; //PB0 – PB7 (LED)출력

	DDRD = 0x00; // PD0 - PD7 (switch) 입력으로 설정	
	PORTD = 0xff; // 포트D 초기 값 
	
	DDRF = 0b00001111; //PF0 - PF3 (FND digit select) 출력
	
	// 모든 LED와 FND를 끈 상태로 초기화
	PORTF = 0x00; // 
	PORTB = 0x00; // 
	PORTA = 0x00; // 
	static unsigned char led_pattern = 0x01; //Mode 2 시프트 패턴 저장용 변수
    unsigned char sw_old = 0xFF; // 0b11111111 (모든 스위치 떼어진 상태) 토글링을 위한 '이전 상태' 저장용 변수
	while(1) {
	unsigned char display_data[4];
	
	unsigned char sw_input = PIND; //스위치 값 읽기 
	unsigned char mode_sw = sw_input & 0x0F; // 하위 4비트만 읽기 (X0 ~ X3)
	
	if(mode_sw == 0x0E) //mode 0
		{
		display_data[3] = segment[0]; // '0' (Q3 자리)
        display_data[2] = segment[5]; // '-' (Q2 자리)
        display_data[1] = segment[4]; // 'S' (Q1 자리)
        display_data[0] = segment[0]; // '0' (Q0 자리)
		
		if((sw_input & 0xF0) == 0xF0) //X4~X7 모두 up(1)
			{
			PORTB = 0x00;	//모든 LED OFF	
			}
		else if((sw_input & 0x10) == 0x00) X4 down(0)
			{
			PORTB = 0x04; Y2만 ON (0b0000 0100)
			}
		else if ((sw_input & 0x20) == 0x00) // X5 down(0)
            	{
                PORTB = 0x05; // Y2, Y0 ON (0b0000 0101)
            	}
        else if ((sw_input & 0x40) == 0x00) // X6 down(0)
            	{
                PORTB = 0x06; // Y2, Y1 ON (0b0000 0110)
            	}	
        else if ((sw_input & 0x80) == 0x00) // X7 down(0)
            	{
                PORTB = 0x07; // Y2, Y1, Y0 ON (0b0000 0111)
            	}
		}
	else if(mode_sw == 0x0D) // Mode 1
		{
		display_data[3] = segment[1]; // '1'
        display_data[2] = segment[5]; // '-'
        display_data[1] = segment[4]; // 'S'
        display_data[0] = segment[1]; // '1'
		
		if (((sw_input & 0x10) == 0x00) && ((sw_old & 0x10) != 0x00)) {
            PORTB ^= (1 << 4); // Y4(PB4) 토글
            }
            // X5를 '누르는 순간' Y5 토글
            if (((sw_input & 0x20) == 0x00) && ((sw_old & 0x20) != 0x00)) {
            PORTB ^= (1 << 5); // Y5(PB5) 토글
            }
            // X6를 '누르는 순간' Y6 토글
            if (((sw_input & 0x40) == 0x00) && ((sw_old & 0x40) != 0x00)) {
            PORTB ^= (1 << 6); // Y6(PB6) 토글
            }
            // X7를 '누르는 순간' Y7 토글
            if (((sw_input & 0x80) == 0x00) && ((sw_old & 0x80) != 0x00)) {
            PORTB ^= (1 << 7); // Y7(PB7) 토글
            }
		}
	else if(mode_sw == 0x0B) // Mode 2
		{
		display_data[3] = segment[2]; // '2'
        display_data[2] = segment[5]; // '-'
        display_data[1] = segment[4]; // 'S'
        display_data[0] = segment[2]; // '2'

			if ((sw_input & 0x10) == 0x00) 
            {
                // 현재 패턴을 왼쪽으로 한 칸만 민다
                led_pattern = led_pattern << 1; 
                // 만약 Y7을 넘어 0이 되면 Y0으로 리셋
                if (led_pattern == 0) 
                {
                led_pattern = 0x01; 
                }
                //계산된 패턴을 LED에 표시
                PORTB = led_pattern;
			}
			// X5 down: Shift Right
            else if ((sw_input & 0x20) == 0x00) 
            {
                led_pattern = led_pattern >> 1; // 오른쪽으로 한 칸
                if (led_pattern == 0) 
                {
                    led_pattern = 0x80; // Y7로 리셋
                }
                PORTB = led_pattern;
		    }
		    // X6 down (2개씩 좌측)
            else if ((sw_input & 0x40) == 0x00) 
            {
                // 1. 하위 4비트(Y0~Y3)만 떼서 시프트
                unsigned char n_low = (led_pattern & 0x0F) << 1; 
                // 2. 상위 4비트(Y4~Y7)만 떼서 시프트
                unsigned char n_high = (led_pattern & 0xF0) << 1;
                // 3. 하위 그룹이 0이 되면 (Y3->밀려남), Y0로 리셋
                if ((n_low & 0x0F) == 0) n_low = 0x01; 
                // 4. 상위 그룹이 0이 되면 (Y7->밀려남), Y4로 리셋
                if (n_high == 0) n_high = 0x10; 
                // 5. 두 결과를 다시 합치기
                led_pattern = (n_high & 0xF0) | (n_low & 0x0F);   
                PORTB = led_pattern;
            }
            // X7 down(2개씩 우측)
            else if ((sw_input & 0x80) == 0x00) 
            {
                // 1. 하위 4비트(Y0~Y3)만 떼서 시프트
                unsigned char n_low = (led_pattern & 0x0F) >> 1; 
                // 2. 상위 4비트(Y4~Y7)만 떼서 시프트
                unsigned char n_high = (led_pattern & 0xF0) >> 1;
                // 3. 하위 그룹이 0이 되면 (Y0->밀려남), Y3로 리셋
                if ((n_low & 0x0F) == 0) n_low = 0x08; 
                // 4. 상위 그룹이 0이 되면 (Y4->밀려남), Y7로 리셋
                if (n_high == 0) n_high = 0x80; 
                // 5. 두 결과를 다시 합치기
                led_pattern = (n_high & 0xF0) | (n_low & 0x0F);   
                PORTB = led_pattern;
            }
            // X4~X7 스위치가 모두 떼어졌을 때
            else 
            {
                PORTB = 0x00; // 모든 LED OFF 
            }
            
            _delay_ms(150); // 0.15초마다 한 칸씩 움직임
        }
            
	else if(mode_sw == 0x07) // Mode 3
        {
        display_data[3] = segment[3]; // '3'
        display_data[2] = segment[5]; // '-'
        display_data[1] = segment[4]; // 'S'
        display_data[0] = segment[3]; // '3'
		}
	else // 모드 선택 안 됨 (X0~X3이 모두 켜져 있거나 여러 개 눌림)
        	{
            	// FND 끄기
            	display_data[3] = 0x00; 
            	display_data[2] = 0x00;
           	    display_data[1] = 0x00;
            	display_data[0] = 0x00;
            
           	    // LED 끄기
            	PORTB = 0x00;
        	}
        sw_old = sw_input; // 현재 스위치 상태를 이전 상태로 저장
	    display_fnd(display_data);
    }
}
	

