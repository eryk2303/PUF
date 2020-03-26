/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0xfbc00daa */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "/home/eryk/Pulpit/UART/uart_tx.vhd";
extern char *IEEE_P_2592010699;

unsigned char ieee_p_2592010699_sub_2763492388968962707_503743352(char *, char *, unsigned int , unsigned int );


static void work_a_0273074976_3212880686_p_0(char *t0)
{
    char *t1;
    unsigned char t2;
    char *t3;
    char *t4;
    unsigned char t5;
    unsigned char t6;
    char *t7;
    unsigned char t8;
    unsigned char t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    int t14;
    int t15;
    int t16;
    int t17;
    int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    char *t23;

LAB0:    xsi_set_current_line(61, ng0);
    t1 = (t0 + 992U);
    t2 = ieee_p_2592010699_sub_2763492388968962707_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t2 != 0)
        goto LAB2;

LAB4:
LAB3:    t1 = (t0 + 4104);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(62, ng0);
    t3 = (t0 + 1192U);
    t4 = *((char **)t3);
    t5 = *((unsigned char *)t4);
    t6 = (t5 == (unsigned char)2);
    if (t6 != 0)
        goto LAB5;

LAB7:    xsi_set_current_line(91, ng0);
    t1 = (t0 + 4312);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t7 = (t4 + 56U);
    t10 = *((char **)t7);
    *((unsigned char *)t10) = (unsigned char)3;
    xsi_driver_first_trans_fast_port(t1);

LAB6:    goto LAB3;

LAB5:    xsi_set_current_line(63, ng0);
    t3 = (t0 + 1512U);
    t7 = *((char **)t3);
    t8 = *((unsigned char *)t7);
    t9 = (t8 == (unsigned char)3);
    if (t9 != 0)
        goto LAB8;

LAB10:    xsi_set_current_line(88, ng0);
    t1 = (t0 + 4312);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t7 = (t4 + 56U);
    t10 = *((char **)t7);
    *((unsigned char *)t10) = (unsigned char)3;
    xsi_driver_first_trans_fast_port(t1);

LAB9:    goto LAB6;

LAB8:    xsi_set_current_line(64, ng0);
    t3 = (t0 + 4184);
    t10 = (t3 + 56U);
    t11 = *((char **)t10);
    t12 = (t11 + 56U);
    t13 = *((char **)t12);
    *((unsigned char *)t13) = (unsigned char)3;
    xsi_driver_first_trans_fast_port(t3);
    xsi_set_current_line(65, ng0);
    t1 = (t0 + 1992U);
    t3 = *((char **)t1);
    t14 = *((int *)t3);
    t1 = (t0 + 2808U);
    t4 = *((char **)t1);
    t15 = *((int *)t4);
    t2 = (t14 < t15);
    if (t2 != 0)
        goto LAB11;

LAB13:
LAB12:    goto LAB9;

LAB11:    xsi_set_current_line(66, ng0);
    t1 = (t0 + 1992U);
    t7 = *((char **)t1);
    t16 = *((int *)t7);
    t17 = (t16 + 1);
    t1 = (t0 + 4248);
    t10 = (t1 + 56U);
    t11 = *((char **)t10);
    t12 = (t11 + 56U);
    t13 = *((char **)t12);
    *((int *)t13) = t17;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(67, ng0);
    t1 = (t0 + 2152U);
    t3 = *((char **)t1);
    t14 = *((int *)t3);
    t2 = (t14 == 0);
    if (t2 != 0)
        goto LAB14;

LAB16:
LAB15:    xsi_set_current_line(70, ng0);
    t1 = (t0 + 2152U);
    t3 = *((char **)t1);
    t14 = *((int *)t3);
    t2 = (t14 > 0);
    if (t2 != 0)
        goto LAB17;

LAB19:
LAB18:    xsi_set_current_line(75, ng0);
    t1 = (t0 + 2152U);
    t3 = *((char **)t1);
    t14 = *((int *)t3);
    t2 = (t14 == 9);
    if (t2 != 0)
        goto LAB23;

LAB25:    xsi_set_current_line(78, ng0);
    t1 = (t0 + 4248);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t7 = (t4 + 56U);
    t10 = *((char **)t7);
    *((int *)t10) = 0;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(79, ng0);
    t1 = (t0 + 2152U);
    t3 = *((char **)t1);
    t14 = *((int *)t3);
    t2 = (t14 < 9);
    if (t2 != 0)
        goto LAB26;

LAB28:    xsi_set_current_line(82, ng0);
    t1 = (t0 + 4376);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t7 = (t4 + 56U);
    t10 = *((char **)t7);
    *((int *)t10) = 0;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(83, ng0);
    t1 = (t0 + 4312);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t7 = (t4 + 56U);
    t10 = *((char **)t7);
    *((unsigned char *)t10) = (unsigned char)3;
    xsi_driver_first_trans_fast_port(t1);

LAB27:
LAB24:    goto LAB12;

LAB14:    xsi_set_current_line(68, ng0);
    t1 = (t0 + 4312);
    t4 = (t1 + 56U);
    t7 = *((char **)t4);
    t10 = (t7 + 56U);
    t11 = *((char **)t10);
    *((unsigned char *)t11) = (unsigned char)2;
    xsi_driver_first_trans_fast_port(t1);
    goto LAB15;

LAB17:    xsi_set_current_line(71, ng0);
    t1 = (t0 + 2152U);
    t4 = *((char **)t1);
    t15 = *((int *)t4);
    t5 = (t15 < 9);
    if (t5 != 0)
        goto LAB20;

LAB22:
LAB21:    goto LAB18;

LAB20:    xsi_set_current_line(72, ng0);
    t1 = (t0 + 1352U);
    t7 = *((char **)t1);
    t1 = (t0 + 2152U);
    t10 = *((char **)t1);
    t16 = *((int *)t10);
    t17 = (t16 - 1);
    t18 = (t17 - 7);
    t19 = (t18 * -1);
    xsi_vhdl_check_range_of_index(7, 0, -1, t17);
    t20 = (1U * t19);
    t21 = (0 + t20);
    t1 = (t7 + t21);
    t6 = *((unsigned char *)t1);
    t11 = (t0 + 4312);
    t12 = (t11 + 56U);
    t13 = *((char **)t12);
    t22 = (t13 + 56U);
    t23 = *((char **)t22);
    *((unsigned char *)t23) = t6;
    xsi_driver_first_trans_fast_port(t11);
    goto LAB21;

LAB23:    xsi_set_current_line(76, ng0);
    t1 = (t0 + 4312);
    t4 = (t1 + 56U);
    t7 = *((char **)t4);
    t10 = (t7 + 56U);
    t11 = *((char **)t10);
    *((unsigned char *)t11) = (unsigned char)3;
    xsi_driver_first_trans_fast_port(t1);
    goto LAB24;

LAB26:    xsi_set_current_line(80, ng0);
    t1 = (t0 + 2152U);
    t4 = *((char **)t1);
    t15 = *((int *)t4);
    t16 = (t15 + 1);
    t1 = (t0 + 4376);
    t7 = (t1 + 56U);
    t10 = *((char **)t7);
    t11 = (t10 + 56U);
    t12 = *((char **)t11);
    *((int *)t12) = t16;
    xsi_driver_first_trans_fast(t1);
    goto LAB27;

}


extern void work_a_0273074976_3212880686_init()
{
	static char *pe[] = {(void *)work_a_0273074976_3212880686_p_0};
	xsi_register_didat("work_a_0273074976_3212880686", "isim/test_isim_beh.exe.sim/work/a_0273074976_3212880686.didat");
	xsi_register_executes(pe);
}
