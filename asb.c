// toy compiler (one-pass assembler and one-pass linker)
// Arthur Jacquin (arthur@jacquin.xyz) - January 2024

// x0: write anything, its read will always return 0
// x1: return value
// x2-5: parameters

// only ASCII file, with lines looking like that (all parts are optionnal):
// label: instruction # comment

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


// CONSTANTS, MACROS, TYPES

#define MAX_LABEL_LENGTH                12
#define MAX_LINE_LENGTH                 100

#define MAX_NB_INSTRUCTIONS             (1 << 12)
#define MAX_NB_LABELS                   MAX_NB_INSTRUCTIONS

#define PARSE_REG(F) { \
    if ((res.F = parse_reg(&start)) == -1) \
        die("parsing failed", 1); \
}
#define PARSE_REG_VAL(S, F) { \
    if ((res.src2 = parse_reg(&start)) != -1)           res.fmt = 0b00; \
    else if ((res.imm = parse_value(&start, S)) != -1)  res.fmt = F; \
    else die("parsing failed", 1); \
}

struct instruction {
    int fmt, op, dst, src1, funct, src2, imm, jump_label_index;
};

struct label {
    char label[MAX_LABEL_LENGTH + 1];
    int address, found;
};

enum mn_type {NOT_TYPE, AND_TYPE, INC_TYPE, POP_TYPE, READ_TYPE, PUSH_TYPE,
    JMP_TYPE, BEQ_TYPE, MOV_TYPE, CAL_TYPE, RET_TYPE};

struct pseudo_instruction {
    char mnemonic[5];
    enum mn_type mn_type;
    int op, funct, mask;
};

struct pseudo_instruction ISA[] = {
    {"not", NOT_TYPE, 0b0000, 0b00, 0},
    {"and", AND_TYPE, 0b0000, 0b01, 0},
    {"or",  AND_TYPE, 0b0000, 0b10, 0},
    {"xor", AND_TYPE, 0b0000, 0b11, 0},

    {"rls", AND_TYPE, 0b0001, 0b00, 0},
    {"lls", AND_TYPE, 0b0001, 0b01, 0},

    {"inc", INC_TYPE, 0b0010, 0b00, 0},
    {"dec", INC_TYPE, 0b0010, 0b01, 0},
    {"add", AND_TYPE, 0b0010, 0b00, 0},
    {"sub", AND_TYPE, 0b0010, 0b01, 0},
    {"mul", AND_TYPE, 0b0010, 0b10, 0},

    {"pop", POP_TYPE, 0b0011, 0b00, 0},
    {"read",READ_TYPE,0b0011, 0b01, 0},
    {"push",PUSH_TYPE,0b0011, 0b10, 0},

    {"jmp", JMP_TYPE, 0b0100, 0,    0},
    {"beq", BEQ_TYPE, 0b0100, 0,    0b1000},
    {"bne", BEQ_TYPE, 0b0100, 0,    0b0100},
    {"bgt", BEQ_TYPE, 0b0100, 0,    0b0110},
    {"bge", BEQ_TYPE, 0b0100, 0,    0b0010},
    {"blt", BEQ_TYPE, 0b0100, 0,    0b0101},
    {"ble", BEQ_TYPE, 0b0100, 0,    0b0001},

    {"mov", MOV_TYPE, 0b0101, 0,    0},

    {"call",CAL_TYPE, 0b0110, 0,    0},

    {"ret", RET_TYPE, 0b0111, 0,    0},

    {""},
};


// GLOBALS

void add_instruction(struct instruction instruction);
void die(const char *msg, int print_current_line);
int eat_line(FILE *stream);
int get_label_index(const char *label, int found, int address);
void int_to_buf(char buf[], int buf_size, int value);
void link_print(struct instruction instruction);
void parse_instruction(void);
int parse_label(char buf[], const char **str);
int parse_reg(const char **str);
int parse_value(const char **str, int size);

char current_line[MAX_LINE_LENGTH + 2];
int current_line_nb, nb_instructions, nb_labels;
struct label labels[MAX_NB_LABELS];
struct instruction instructions[MAX_NB_INSTRUCTIONS];


// FUNCTIONS

void
add_instruction(struct instruction instruction)
{
    if (nb_instructions == MAX_NB_INSTRUCTIONS)
        die("too much instructions", 1);
    instructions[nb_instructions++] = instruction;
}

void
die(const char *msg, int print_current_line)
{
    fprintf(stderr, "[ERROR] %s\n", msg);
    if (print_current_line)
        fprintf(stderr, "%d: %s\n", current_line_nb, current_line);
    exit(EXIT_FAILURE);
}

int
eat_line(FILE *stream)
{
    if (!fgets(current_line, MAX_LINE_LENGTH, stream))
        return 1;
    if (current_line[strlen(current_line) - 1] != '\n')
        die("line is too long", 1);
    current_line[strlen(current_line) - 1] = '\0';
    return 0;
}

int
get_label_index(const char *label, int found, int address)
{
    int i;

    for (i = 0; i < nb_labels && strcmp(label, labels[i].label); i++);
    if (i == nb_labels) {
        if (nb_labels++ == MAX_NB_INSTRUCTIONS)
            die("too much labels", 1);
        strcpy(labels[i].label, label);
        labels[i].found = found;
        labels[i].address = address;
    } else if (found) {
        if (labels[i].found)
            die("label is already used", 1);
        labels[i].found = found;
        labels[i].address = address;
    }
    return i;
}

void
int_to_buf(char buf[], int buf_size, int value)
{
    int i;

    for (i = 0; i < buf_size; i++, value >>= 1)
        buf[buf_size - 1 - i] = (value & 1) ? '1' : '0';
}

void
link_print(struct instruction instruction)
{
    char buf[27];
    int index;

    int_to_buf(buf + 0, 2, instruction.fmt);
    int_to_buf(buf + 2, 4, instruction.op);
    int_to_buf(buf + 6, 4, instruction.dst);
    if (instruction.fmt < 2) {
        int_to_buf(buf + 10, 4, instruction.src1);
        int_to_buf(buf + 14, 2, instruction.funct);
        if (instruction.fmt == 0) {
            int_to_buf(buf + 16, 6, 0);
            int_to_buf(buf + 22, 4, instruction.src2);
        } else
            int_to_buf(buf + 16, 10, instruction.imm);
    } else {
        index = instruction.jump_label_index;
        int_to_buf(buf + 10, 16, (index == -1) ? instruction.imm : labels[index].address);
    }
    buf[26] = '\0';
    printf("%s\n", buf);
}

void
parse_instruction(void)
{
    const char *start, *space, *end;
    char label[MAX_LABEL_LENGTH + 1];
    int length, type, x;
    struct instruction res;
    struct pseudo_instruction *pseudo;

    // parse and register label
    if ((start = strchr(current_line, ':'))) {
        if ((end = strchr(current_line, '#')) && end < start)
            return;
        if ((length = start - current_line) > MAX_LABEL_LENGTH)
            die("label is too long", 1);
        else if (!length)
            die("label must be non-empty", 1);
        strncpy(label, current_line, length);
        label[length] = '\0';
        get_label_index(label, 1, nb_instructions);
        start++;
    } else
        start = current_line;

    // delimitate instruction
    for (; *start == ' '; start++);
    if (!(end = strchr(start, '#')))
        end = strchr(start, '\0');
    if (start == end)
        return;
    for (end--; *end == ' '; end--);
    end++;

    // detect the mnemonic
    length = (((space = strchr(start, ' '))) ? space : end) - start;
    for (pseudo = ISA; *(pseudo->mnemonic) && (strncmp(pseudo->mnemonic, start,
        length) || (pseudo->mnemonic)[length]); pseudo++);
    if (!(*(pseudo->mnemonic)))
        die("unknown mnemonic", 1);
    for (start += length; *start == ' '; start++);

    // parse arguments
    res.op = pseudo->op;
    res.funct = pseudo->funct;
    res.dst = 0;
    res.src1 = 0;
    res.src2 = 0;
    res.jump_label_index = -1;
    switch (type = pseudo->mn_type) {
    case NOT_TYPE:
        PARSE_REG(dst)
        PARSE_REG(src1)
        res.fmt = 0b00;
        break;
    case AND_TYPE:
        PARSE_REG(dst)
        PARSE_REG(src1)
        PARSE_REG_VAL(10, 0b01)
        break;
    case INC_TYPE:
        PARSE_REG(dst)
        res.src1 = res.dst;
        res.imm = 1;
        res.fmt = 0b01;
        break;
    case POP_TYPE:
        PARSE_REG(dst)
        res.fmt = 0b00;
        break;
    case READ_TYPE:
        PARSE_REG(dst)
        PARSE_REG_VAL(16, 0b10)
        break;
    case PUSH_TYPE:
        PARSE_REG_VAL(16, 0b10)
        break;
    case BEQ_TYPE:
        // perform a substraction
        res.op = 0b0010;
        res.funct = 0b01;
        PARSE_REG(src1)
        PARSE_REG_VAL(10, 0b01)
        add_instruction(res);
        // fall-through
    case JMP_TYPE:
    case CAL_TYPE:
        // perform a jump
        if ((parse_label(label, &start)) == -1)
            die("parsing failed", 1);
        res.fmt = 0b10;
        res.op = pseudo->op;
        res.dst = pseudo->mask;
        res.jump_label_index = get_label_index(label, 0, 0);
        break;
    case MOV_TYPE:
        PARSE_REG(dst)
        PARSE_REG_VAL(16, 0b10)
        break;
    case RET_TYPE:
        res.fmt = 0b00;
        break;
    }
    add_instruction(res);
}

int
parse_label(char buf[], const char **str)
{
    const char *end, *s;
    char stop[3] = " #\0";
    int i, length;

    s = *str;
    for (i = 0; !(end = strchr(s, stop[i])); i++);
    if ((length = end - s) > MAX_LABEL_LENGTH || !length)
        return -1;
    strncpy(buf, s, length);
    buf[length] = '\0';
    for (s += length; *s == ',' || *s == ' '; s++);
    *str = s;
    return 0;
}

int
parse_reg(const char **str)
{
    const char *s;
    int res;

    s = *str;
    if (*s++ != 'x' || !isdigit(*s))
        return -1;
    res = *s++ - '0';
    if (isdigit(*s))
        res = res*10 + *s++ - '0';
    for (; *s == ',' || *s == ' '; s++);
    if (res >= 16)
        return -1;
    *str = s;
    return res;
}

int
parse_value(const char **str, int size)
{
    const char *end, *s;
    char stop[3] = " #\0";
    int i, res;

    s = *str;
    if (sscanf(s, "%d", &res) != 1)
        return -1;
    if (res < 0)
        die("value must be positive", 1);
    if (res >> size)
        die("value is too big", 1);
    for (i = 0; !(end = strchr(s, stop[i])); i++);
    for (s = end; *s == ',' || *s == ' '; s++);
    *str = s;
    return res;
}


int
main(int argc, char *argv[])
{
    FILE *src_file;
    char err_msg[18 + MAX_LABEL_LENGTH];
    int i;

    // check arguments, open file
    if (argc != 2)
        die("usage: asb filename", 0);
    if (!(src_file = fopen(argv[1], "r")))
        die("can't open the file", 0);

    // parse and close file
    for (current_line_nb = 1; !eat_line(src_file); current_line_nb++)
        parse_instruction();
    fclose(src_file);

    // link and output
    for (i = 0; i < nb_labels; i++)
        if (!(labels[i].found)) {
            sprintf(err_msg, "label not found: %s", labels[i].label);
            die(err_msg, 0);
        }
    for (i = 0; i < nb_instructions; i++)
        link_print(instructions[i]);

    return 0;
}
