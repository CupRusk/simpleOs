#define VGA_ADDRESS 0xB8000


int cursor_x = 0;
int cursor_y = 0;
// имена функций писать CupRuska_<Обозначения функций> <-- обозначения кто сделал, кого коммит.



void CupRuska_print(const char* str) {
    while(*str != 0) {
        char* video = (char*)VGA_ADDRESS + (cursor_y * 80 + cursor_x) * 2; // VGA онли, я не знаю как HDMI... надо будет посмотреть как

        if(*str == '\n') {
            cursor_x = 0; // перевод на начало строки
            cursor_y++; // ниже
            if(cursor_y >= 25) cursor_y = 0; // простая прокрутка
            str++;
            video = (char*)VGA_ADDRESS + cursor_y * 160;
            continue;
        }

        *video++ = *str++;
        *video++ = 0x0F; // белый на черном
        cursor_x++;

        if(cursor_x >= 80) { // перенос строки, если дошли до края
            cursor_x = 0;
            cursor_y++;
            if(cursor_y >= 25) cursor_y = 0;
        }
    }
}

void CupRuska_clear_print() {
    for(int y = 0; y < 25; y++) {
        for(int x = 0; x < 80; x++) {
                char* video = (char*)VGA_ADDRESS + (y * 80 + x) * 2;
                *video = ' ';
                *(video + 1) = 0x0F;
            }
        }
    cursor_x = 0;
    cursor_y = 0;
}


void main() {
    CupRuska_print("Hello. \n This is a test.");

   // Надо написать таймер PTI CupRuska_clear_print();
    CupRuska_print("Hello. \n This is a test Timer.");

    while(1);
}
