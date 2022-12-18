#include <neorv32.h>
#include <math.h>
#include "image.h"

/**********************************************************************//**
 * @name User configuration
 **************************************************************************/
/**@{*/
/** UART BAUD rate */
#define BAUD_RATE 19200
/**@}*/
#define IMG_SIZE 100
#define NEW_IMG_SIZE 200
#define LINHAS 100
#define COLUNAS 100
#define HEADER_SIZE 54 // Tamanho do cabeçalho do arquivo BMP

uint8_t matrizNewImage[NEW_IMG_SIZE*NEW_IMG_SIZE*3 + HEADER_SIZE];
int main() {
    // init UART0 at default baud rate, no parity bits, no HW flow control
    neorv32_uart0_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);

    neorv32_rte_setup();

    // check if CFS is implemented at all
    if (neorv32_cfs_available() == 0) {
        neorv32_uart0_printf("Error! No CFS synthesized!\n");
        return 1;
    }

    //insere o angulo;
    NEORV32_CFS.REG[1] = 30;


    // Como estamos utilizando RGB - Cada ponto da nossa imagem vai ter 3 inteiros que formam o RGB
    uint32_t maxbla = NEW_IMG_SIZE*NEW_IMG_SIZE*3 + HEADER_SIZE;

    // preenche a imagem com branco
    for (uint32_t i = 0; i < maxbla; i++) {
        matrizNewImage[i] = 255;
    }

    // copia o header da foto antiga para a foto nova
    for (uint8_t i = 0; i < HEADER_SIZE; i++) {
        matrizNewImage[i] = a_bmp[i];
    }


    // Mudando o tamanho da imagem para 200 x 200.
    matrizNewImage[18] = NEW_IMG_SIZE;
    matrizNewImage[22] = NEW_IMG_SIZE;

    uint16_t pos_y;                   
    uint16_t pos_x;         
    uint32_t pos_new_x;
    uint32_t pos_new_y;
    uint8_t collorR;
    uint8_t collorG;
    uint8_t collorB;

    for (uint16_t i=0; i < IMG_SIZE; i++) {
        for (uint16_t j=0; j < IMG_SIZE; j++) {
            pos_y = i;
            pos_x = j;


            NEORV32_CFS.REG[3] = pos_x;
            NEORV32_CFS.REG[4] = pos_y;

            pos_new_x = NEORV32_CFS.REG[5];
            pos_new_y = NEORV32_CFS.REG[6];

            uint32_t posInArray = ((pos_y * IMG_SIZE + pos_x) * 3) + HEADER_SIZE;

            collorB = a_bmp[posInArray];
            collorG = a_bmp[posInArray + 1];
            collorR = a_bmp[posInArray + 2];

            uint32_t newPosInArray = ((pos_new_y * NEW_IMG_SIZE + pos_new_x) * 3) + HEADER_SIZE;

            matrizNewImage[newPosInArray] = collorB;
            matrizNewImage[newPosInArray + 1] = collorG;
            matrizNewImage[newPosInArray + 2] = collorR;
        }
    }

    for (uint32_t i=0; i<maxbla;i++){
        neorv32_uart0_printf("%X", matrizNewImage[i]);
    }

    neorv32_uart0_printf("\nImage rotated.\n");

    return 0;
}
