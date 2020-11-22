%{

//Translator file containing data structures and function prototype
    #include "ass6_18CS10062_18CS10067_translator.h"
    void yyerror(const char*);
    extern int yylex(void);
    using namespace std;
%}

//declaring data types to be included in yylval
%union{
    int intval;   //to hold the value of integer constant
    char charval; //to hold the value of character constant
    identifier idl;    // to define the type for Identifier
    float floatval; //to hold the value of floating constant
    string *strval; // to hold the value of enumberation scnstant
    decStr decl;   //to define the declarators
    argsList argsl; //to define the argumnets list
    int instr;  // to defin the type used by M->(epsilon)
    expresn expon;   // to define the structure of expression
    list *nextlist;  //to define the nextlist type for N->(epsilon)
}

// -------------------------- TOKEN DECLARATION --------------------------------

%token <idl> IDENTIFIER  
%token <intval> INTEGER_CONSTANT
%token <floatval> FLOATING_CONSTANT
%token <charval> CHAR_CONST
%token <strval> STRING_LITERAL

%token ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE
%token SQUARE_BRACKET_OPEN SQUARE_BRACKET_CLOSE
%token CURLY_BRACKET_OPEN CURLY_BRACKET_CLOSE

%token BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE 

%token POINTER UNARY_INCREMENT UNARY_DECREMENT LEFT_SHIFT RIGHT_SHIFT LESS_EQUALS GREATER_EQUALS EQUALS NOT_EQUALS ASSIGN 
%token DOT QUES COLON SEMICOLON 

%token LOGICAL_AND LOGICAL_OR ELLIPSIS MULTIPLY_ASSIGN DIVIDE_ASSIGN MODULO_ASSIGN ADD_ASSIGN SUBTRACT_ASSIGN
%token BITWISE_LEFT_ASSIGN  BITWISE_RIGHT_ASSIGN  BITWISE_AND_ASSIGN  XOR_ASSIGN BITWISE_OR_ASSIGN  
%token SINGLE_LINE_COMMENT MULTI_LINE_COMMENT

//Expressions
%type <expon> 
    primary_expression 
    postfix_expression 
    unary_expression 
    cast_expression 
    multiplicative_expression 
    additive_expression 
    shift_expression 
    relational_expression 
    equality_expression 
    AND_expression 
    exclusive_OR_expression 
    inclusive_OR_expression 
    logical_AND_expression 
    logical_OR_expression 
    conditional_expression 
    assignment_expression_opt 
    assignment_expression 
    constant_expression 
    expression 
    expression_statement 
    expression_opt 
    declarator 
    direct_declarator 
    initializer 
    identifier_opt 
    declaration 
    init_declarator_list 
    init_declarator_list_opt 
    init_declarator

//list of arguments in the statement block
%type <nextlist> 
    block_item_list 
    block_item statement 
    labeled_statement 
    compound_statement 
    selection_statement 
    iteration_statement 
    jump_statement 
    block_item_list_opt

//list of arguments
%type <argsl> 
    argument_expression_list 
    argument_expression_list_opt

//declaration
%type <decl> 
    type_specifier 
    declaration_specifiers 
    specifier_qualifier_list 
    type_name 
    pointer 
    pointer_opt

//Auxillary non-terminals M and N used for backpatching
%type <instr>       M
%type <nextlist>    N

//unary operator
%type <charval>     unary_operator

//setting the precedence and associativity of arithmetic operators
%left '+' '-'
%left '*' '/' '%'
%nonassoc UNARY

//Setting precedence for handling Dangling-if-else shift-reduce conflict
%nonassoc IF_CONFLICT
%nonassoc ELSE

// ------------------------ STATING THE STARTING NON-TERMINAL SYMBOL ------------
%start translation_unit

%%
M:
        {
            // backpatching,stores the index of the next quad to be generated
            // Used in various control statements
            $$ = next_instr;
        };

N:
        {
            // backpatching,inserts a goto and stores the index of the next goto statement in the globl quad to guard against fallthrough
            $$ = makelist(next_instr);          //create a new next list
            glob_quad.emit(Q_GOTO, -1);
        };

// -------------------------------- 1. EXPRESSIONS ------------------------------

primary_expression
        :IDENTIFIER 
        {
            //CASE :: check for FUNCTION
            symdata * check_func = glob_st->search(*$1.name);   //search identifier in global symbol table
            if(check_func == NULL)                              //if identifier is not found in the global ST
            {
                $$.loc  =  curr_st->lookup_2(*$1.name);         //search identifier in the current symbol table
                if($$.loc->tp_n != NULL && $$.loc->tp_n->basetp == tp_arr)
                {
                    //CASE :: ARRAY
                    $$.arr = $$.loc;                                //set location of primary expr
                    $$.loc = curr_st->gentemp(new type_n(tp_int));  //generate temporary
                    $$.loc->i_val.int_val = 0;                      //set initial values of temporary
                    $$.loc->isInitialized = true;
                    glob_quad.emit(Q_ASSIGN,0,$$.loc->name);        //assign the value of identifier to temporary
                    $$.type = $$.arr->tp_n;
                    $$.poss_array = $$.arr;
                    update_nextinstr();                             //update instruction number
                }
                else
                {
                    //CASE :: NOT AN ARRAY
                    $$.type = $$.loc->tp_n;       //set data type of identifier
                    $$.arr = NULL;                //not an array Case
                    $$.isPointer = false;         //not a pointer
                    update_nextinstr();           //update instruction nunmber
                }
            }
            else                        //if identifier is present in current ST
            {
                $$.loc = check_func;            //set location as present address in ST
                $$.type = check_func->tp_n;
                $$.arr = NULL;                  //not an array
                $$.isPointer = false;           //not a pointer
                update_nextinstr();             //update instruction number
            }
        } 
        |INTEGER_CONSTANT 
        {
            $$.loc  = curr_st->gentemp(new type_n(tp_int));     //generate a temporary
            $$.type = $$.loc->tp_n;                             
            $$.loc->i_val.int_val = $1;                         //initialise temporary with the integer constant value
            $$.loc->isInitialized = true;
            $$.arr = NULL;                                      //not an array case
            glob_quad.emit(Q_ASSIGN, $1, $$.loc->name);         //create a global quad of the temporary
            update_nextinstr();                                 //update the instruction number
        } 
        |FLOATING_CONSTANT 
        {
            $$.loc  = curr_st->gentemp(new type_n(tp_double));  //generate a temporary
            $$.type = $$.loc->tp_n;
            $$.loc->i_val.double_val = $1;                      //initialise temporary with the float constant value
            $$.loc->isInitialized = true;
            $$.arr = NULL;                                      //not an array case
            glob_quad.emit(Q_ASSIGN, $1, $$.loc->name);         //create a global quad of the temporary
            update_nextinstr();                                 //update the instruction number
        } 
        |CHAR_CONST 
        {
            $$.loc  = curr_st->gentemp(new type_n(tp_char));     //generate a temporary
            $$.type = $$.loc->tp_n;
            $$.loc->i_val.char_val = $1;                        //initialise temporary with the character constant value
            $$.loc->isInitialized = true;
            $$.arr = NULL;                                      //not an array case
            glob_quad.emit(Q_ASSIGN, $1, $$.loc->name);         //create a global quad of the temporary
            update_nextinstr();                                 //update the instruction number
        } 
        |STRING_LITERAL 
        {
            strings_label.push_back(*$1);               //set base address of string
            $$.loc = NULL;
            $$.isString = true;                         //set as string value
            $$.ind_str = strings_label.size()-1;
            $$.arr = NULL;
            $$.isPointer = false;                       //not a pointer case
            update_nextinstr();                         //update the instruction number
        } 
        |ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE                             //expression
        {
            $$ = $2;                                    //equating the value of expressions
        }
        ;

postfix_expression 
        :primary_expression 
        {
            $$ = $1;                                //equating the value of expressions
        } 
        |postfix_expression SQUARE_BRACKET_OPEN expression SQUARE_BRACKET_CLOSE      //CASE :: Array handling
        {
            $$.loc = curr_st->gentemp(new type_n(tp_int));              //generate a temporary
            symdata* temporary = curr_st->gentemp(new type_n(tp_int));  //assign a location to the temporary in the current ST

            char temp[10];
            sprintf(temp,"%d",$1.type->next->getSize());                //calculate the address of the array 
            glob_quad.emit(Q_MULT,$3.loc->name,temp,temporary->name);
            update_nextinstr();
            glob_quad.emit(Q_PLUS,$1.loc->name,temporary->name,$$.loc->name);
            update_nextinstr();

            $$.arr = $1.arr;                //set the base pointer of the array
            $$.type = $1.type->next;        //set the data type   
            $$.poss_array = NULL;
        } 
        |postfix_expression ROUND_BRACKET_OPEN argument_expression_list_opt ROUND_BRACKET_CLOSE    //CASE :: function handling
        {
            if(!$1.isPointer && !$1.isString && ($1.type) && ($1.type->basetp==tp_void))
            {
                update_nextinstr();                                 //update the next instruction number
            }
            else
                $$.loc = curr_st->gentemp(duplicateType($1.type));       //generate a temporary
            char str[10];
            if($3.arguments == NULL)        //check if function argument list is empty
            {
                sprintf(str,"0");
                if($1.type->basetp!=tp_void)        //call the function
                    glob_quad.emit(Q_CALL,$1.loc->name,str,$$.loc->name);
                else
                    glob_quad.emit2(Q_CALL,$1.loc->name,str);
                update_nextinstr();
            }
            else                            //else point to the argument list and call the function along with # of arguments
            {   
                if((*$3.arguments)[0]->isString)       
                {
                    str[0] = '_';
                    sprintf(str+1,"%d",(*$3.arguments)[0]->ind_str);
                    glob_quad.emit(PARAM,str);
                    glob_quad.emit(Q_CALL,$1.loc->name,"1",$$.loc->name);
                    update_nextinstr();
                }
                else
                {
                    for(int i=0;i<$3.arguments->size();i++)         //print all the arguments of the function
                    {
                        if((*$3.arguments)[i]->poss_array != NULL && $1.loc->name != "printInt")
                            glob_quad.emit(PARAM,(*$3.arguments)[i]->poss_array->name);
                        else
                            glob_quad.emit(PARAM,(*$3.arguments)[i]->loc->name);

                    }
                    sprintf(str,"%ld",$3.arguments->size());
                    if($1.type->basetp!=tp_void)
                        glob_quad.emit(Q_CALL,$1.loc->name,str,$$.loc->name);
                    else
                        glob_quad.emit2(Q_CALL,$1.loc->name,str);
                    update_nextinstr();
                }
            }

            $$.arr = NULL;
            $$.type = $$.loc->tp_n;
            update_nextinstr();
        } 
        |postfix_expression DOT IDENTIFIER         {    }
        |postfix_expression POINTER IDENTIFIER     {    } 
        |postfix_expression UNARY_INCREMENT 
        {
            $$.loc = curr_st->gentemp(duplicateType($1.type));   //generate a temporary
            if($1.arr != NULL)                              //if expr is an array
            {
                // Perform postfix increment of the array value
                symdata * temp_elem = curr_st->gentemp(duplicateType($1.type));
                glob_quad.emit(Q_RINDEX,$1.arr->name,$1.loc->name,$$.loc->name);
                glob_quad.emit(Q_RINDEX,$1.arr->name,$1.loc->name,temp_elem->name);
                glob_quad.emit(Q_PLUS,temp_elem->name,"1",temp_elem->name);
                glob_quad.emit(Q_LINDEX,$1.loc->name,temp_elem->name,$1.arr->name);
                $$.arr = NULL;
            }
            else
            {
                // Perform postfix increment of the array value
                glob_quad.emit(Q_ASSIGN,$1.loc->name,$$.loc->name);
                glob_quad.emit(Q_PLUS,$1.loc->name,"1",$1.loc->name); 
            }
            $$.type = $$.loc->tp_n;                  
            update_nextinstr();                             //update the instruction number
        } 
        |postfix_expression UNARY_DECREMENT 
        {
            $$.loc = curr_st->gentemp(duplicateType($1.type));  //generate a temporary
            if($1.arr != NULL)
            {
                // Peform Post decrement of an array element
                symdata * temp_elem = curr_st->gentemp(duplicateType($1.type));
                glob_quad.emit(Q_RINDEX,$1.arr->name,$1.loc->name,$$.loc->name);
                glob_quad.emit(Q_RINDEX,$1.arr->name,$1.loc->name,temp_elem->name);
                glob_quad.emit(Q_MINUS,temp_elem->name,"1",temp_elem->name);
                glob_quad.emit(Q_LINDEX,$1.loc->name,temp_elem->name,$1.arr->name);
                $$.arr = NULL;
            }
            else
            {
                //post decrement of an simple element
                glob_quad.emit(Q_ASSIGN,$1.loc->name,$$.loc->name);
                glob_quad.emit(Q_MINUS,$1.loc->name,"1",$1.loc->name);
            }
            $$.type = $$.loc->tp_n;
            update_nextinstr();                             //update the instruction number
        } 
        |ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN initializer_list CURLY_BRACKET_CLOSE     {   }
        |ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN initializer_list ',' CURLY_BRACKET_CLOSE {   }
        ;

argument_expression_list
        :assignment_expression 
        {
            $$.arguments = new vector<expresn*>;            //create a list of arguments
            expresn *expr = new expresn($1);                //create a new expr for the assignment expr
            $$.arguments->push_back(expr);                  //push the new expr 
            update_nextinstr();                             //update the instruction number
        }
        |argument_expression_list ',' assignment_expression 
        {
            expresn *expr = new expresn($3);                //create a new expr for the assignment expr
            $$.arguments->push_back(expr);                  //push the new expr
            update_nextinstr();                             //update the instruction number
        }
        ;

argument_expression_list_opt
        :argument_expression_list
        {
            $$ = $1;                //equating the value of the 2 argument list
            update_nextinstr();     //update the next instruction number
        }
        |/*empty*/
        {
            $$.arguments = NULL;    //set argument list as empty
            update_nextinstr();     //update the next instruction number
        }
        ;

unary_expression
        :postfix_expression 
        {
            $$ = $1;                //equating the value of the 2 expressions
            update_nextinstr();     //update the next instruction number
        }
        |UNARY_INCREMENT unary_expression 
        {
            //Peform pre increment of the unary expr
            $$.loc = curr_st->gentemp($2.type);             //generating  a temporary to store the expr
            if($2.arr != NULL)      //if unary expression is an array
            {
                //Perform pre increment of an Array element 
                symdata * temp_elem = curr_st->gentemp(duplicateType($2.type));
                glob_quad.emit(Q_RINDEX,$2.arr->name,$2.loc->name,temp_elem->name);
                glob_quad.emit(Q_PLUS,temp_elem->name,"1",temp_elem->name);
                glob_quad.emit(Q_LINDEX,$2.loc->name,temp_elem->name,$2.arr->name);
                glob_quad.emit(Q_RINDEX,$2.arr->name,$2.loc->name,$$.loc->name);
                $$.arr = NULL;
            }
            else                    //if unary expr is not an array element
            {
                //Perform pre increment of the simple element
                glob_quad.emit(Q_PLUS,$2.loc->name,"1",$2.loc->name);
                glob_quad.emit(Q_ASSIGN,$2.loc->name,$$.loc->name);
            }
            $$.type = $$.loc->tp_n;
            update_nextinstr();     //update the next instruction number
        }
        |UNARY_DECREMENT unary_expression 
        {   
            //Peform pre decrement of the unary expr
            $$.loc = curr_st->gentemp(duplicateType($2.type));       //generating a temporary to store the expr
            if($2.arr != NULL)      //if unary expr is an array
            {
                //pre decrement of  Array Element 
                symdata * temp_elem = curr_st->gentemp(duplicateType($2.type));
                glob_quad.emit(Q_RINDEX,$2.arr->name,$2.loc->name,temp_elem->name);
                glob_quad.emit(Q_MINUS,temp_elem->name,"1",temp_elem->name);
                glob_quad.emit(Q_LINDEX,$2.loc->name,temp_elem->name,$2.arr->name);
                glob_quad.emit(Q_RINDEX,$2.arr->name,$2.loc->name,$$.loc->name);
                $$.arr = NULL;
            }
            else
            {
                // pre decrement
                glob_quad.emit(Q_MINUS,$2.loc->name,"1",$2.loc->name);
                glob_quad.emit(Q_ASSIGN,$2.loc->name,$$.loc->name);
            }
            $$.type = $$.loc->tp_n;
            update_nextinstr();         //update the next instruction number
        }
        |unary_operator cast_expression
        {
            type_n * temp_type;
            switch($1)
            {
            case '&':
                //create a temporary type store the type
                temp_type = new type_n(tp_ptr,1,$2.type);
                $$.loc = curr_st->gentemp(duplicateType(temp_type));     //generate a temporary to store expr
                $$.type = $$.loc->tp_n;
                glob_quad.emit(Q_ADDR,$2.loc->name,$$.loc->name);
                update_nextinstr();                                 //update the next instruction number
                $$.arr = NULL;
            break;
            case '*':
                $$.isPointer = true;
                $$.type = $2.loc->tp_n->next;
                $$.loc = $2.loc;
                $$.arr = NULL;              //not an array case
                update_nextinstr();         //update the next instruction number
            break;
            case '+':
                $$.loc = curr_st->gentemp(duplicateType($2.type));       //generate a temporary to store the value
                $$.type = $$.loc->tp_n;
                glob_quad.emit(Q_ASSIGN,$2.loc->name,$$.loc->name);
                update_nextinstr();        //update the next instruction number
            break;
            case '-':
                $$.loc = curr_st->gentemp(duplicateType($2.type));       //generate temporary
                $$.type = $$.loc->tp_n;     //set the data type of value
                glob_quad.emit(Q_UNARY_MINUS,$2.loc->name,$$.loc->name);
                update_nextinstr();        //update the next instruction number
            break;
            case '~':
                $$.loc = curr_st->gentemp(duplicateType($2.type));       //generate temporary
                $$.type = $$.loc->tp_n;
                glob_quad.emit(Q_NOT,$2.loc->name,$$.loc->name);
                update_nextinstr();        //update the next instruction number
            break;
            case '!':
                $$.loc = curr_st->gentemp(duplicateType($2.type));       //generate temporary
                $$.type = $$.loc->tp_n;
                $$.truelist = $2.falselist;
                $$.falselist = $2.truelist;
                update_nextinstr();         //update the next instruction number
            break;
            default:
                update_nextinstr();         //update the next instruction number
            break;
            }
        }
        |SIZEOF unary_expression     {  }
        |SIZEOF ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE    {  } 
        ;

unary_operator  
        :'&'                    //bitwsise_and
        {
            $$ = '&';           //assignment of operator
        }
        |'*'                    //multiplication
        {
            $$ = '*';           //assignment of operator
        }
        |'+'                    //addition
        {
            $$ = '+';           //assignment of operator
        }
        |'-'                    //subtraction
        {
            $$ = '-';           //assignment of operator
        }
        |'~'                    //complement
        {
            $$ = '~';           //assignment of operator
        }
        |'!'                    //not operator
        {
            $$ = '!';           //assignment of operator
        }
        ;

cast_expression 
        :unary_expression 
        {
            if($1.arr != NULL && $1.arr->tp_n != NULL&& $1.poss_array==NULL)
            {
                //Right Indexing of an array element as unary expression is converted into cast expression
                $$.loc = curr_st->gentemp(new type_n($1.type->basetp));     //generate temporary
                glob_quad.emit(Q_RINDEX,$1.arr->name,$1.loc->name,$$.loc->name);
                $$.arr = NULL;                  //not an array case
                $$.type = $$.loc->tp_n;
                update_nextinstr();             //update the next instruction number
            }
            else if($1.isPointer == true)
            {
                //RDereferencing as its a pointer
                $$.loc = curr_st->gentemp(duplicateType($1.type));
                $$.isPointer = false;
                glob_quad.emit(Q_RDEREF,$1.loc->name,$$.loc->name);
                update_nextinstr();             //update the next instruction number
            }
            else
                $$ = $1;                        //equality of expressions
        }
        |ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE cast_expression   {      }
        ;

multiplicative_expression
        :cast_expression 
        {
            $$ = $1;            //equality of expressions
        }
        |multiplicative_expression '*' cast_expression 
        {
            compareExpType(&$1,&$3);              //check data type of 2 expr
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_MULT,$1.loc->name,$3.loc->name,$$.loc->name);  //emit the quad
            update_nextinstr();             //update the next instruction number               
        }
        |multiplicative_expression '/' cast_expression 
        {
            compareExpType(&$1,&$3);             //check data type of 2 expr
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_DIVIDE,$1.loc->name,$3.loc->name,$$.loc->name);  //emit the quad
            update_nextinstr();              //update the next instruction number               
        }
        |multiplicative_expression '%' cast_expression
        {
            compareExpType(&$1,&$3);             //check data type of 2 expr
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_MODULO,$1.loc->name,$3.loc->name,$$.loc->name);    //emit the quad
            update_nextinstr();              //update the next instruction number               
        }
        ;

additive_expression 
        :multiplicative_expression 
        {
            $$ = $1;                //equating the value of 2 expr
        }
        |additive_expression '+' multiplicative_expression 
        {
            compareExpType(&$1,&$3);     //check data type of 2 expr
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_PLUS,$1.loc->name,$3.loc->name,$$.loc->name);
            update_nextinstr();     //update the next instruction number
        }
        |additive_expression '-' multiplicative_expression 
        {
            compareExpType(&$1,&$3);     //check data type of 2 expr
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_MINUS,$1.loc->name,$3.loc->name,$$.loc->name);
            update_nextinstr();     //update the next instruction number
        }
        ;

shift_expression
        :additive_expression 
        {
            $$ = $1;                //equating the value of 2 expressions
        }
        |shift_expression LEFT_SHIFT additive_expression
        {
            $$.loc = curr_st->gentemp($1.type);         //generate a temporary
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_LEFT_OP,$1.loc->name,$3.loc->name,$$.loc->name);
            update_nextinstr();                         //update the next instruction number
        }
        |shift_expression RIGHT_SHIFT additive_expression
        {
            $$.loc = curr_st->gentemp($1.type);         //generate a temporary
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_RIGHT_OP,$1.loc->name,$3.loc->name,$$.loc->name);
            update_nextinstr();                         //update the next instruction number
        }
        ;

relational_expression
        :shift_expression 
        {
            $$ = $1;                   //equality of two expressions
        }
        |relational_expression '<' shift_expression         
        {
            compareExpType(&$1,&$3);                               //check compatibility of data types of 2 expr
            $$.type = new type_n(tp_bool);                    //set boolean data type
            $$.truelist = makelist(next_instr);               //create a truelist
            $$.falselist = makelist(next_instr+1);            //create a falselist
            glob_quad.emit(IF_LESS,$1.loc->name,$3.loc->name,"-1");
            glob_quad.emit(Q_GOTO,"-1");
            update_nextinstr();                               //update the next instruction number
        }
        |relational_expression '>' shift_expression 
        {
            compareExpType(&$1,&$3);                                 //check compatibility of data types of 2 expr
            $$.type = new type_n(tp_bool);                      //set boolean data type
            $$.truelist = makelist(next_instr);                 //create a truelist
            $$.falselist = makelist(next_instr+1);              //create a falselist
            glob_quad.emit(IF_GREATER,$1.loc->name,$3.loc->name,"-1");
            glob_quad.emit(Q_GOTO,"-1");
            update_nextinstr();                                //update the next instruction number
        }
        |relational_expression LESS_EQUALS shift_expression 
        {
            compareExpType(&$1,&$3);                                 //check compatibility of data types of 2 expr
            $$.type = new type_n(tp_bool);                      //set boolean data type
            $$.truelist = makelist(next_instr);                 //create a truelist
            $$.falselist = makelist(next_instr+1);              //create a falselist
            glob_quad.emit(IF_LESS_OR_EQUAL,$1.loc->name,$3.loc->name,"-1");
            glob_quad.emit(Q_GOTO,"-1");
            update_nextinstr();                                 //update the next instruction number
        }
        |relational_expression GREATER_EQUALS shift_expression 
        {
            compareExpType(&$1,&$3);                                 //check compatibility of data types of 2 expr
            $$.type = new type_n(tp_bool);                      //set boolean data type
            $$.truelist = makelist(next_instr);                 //create a truelist
            $$.falselist = makelist(next_instr+1);              //create a falselist
            glob_quad.emit(IF_GREATER_OR_EQUAL,$1.loc->name,$3.loc->name,"-1");
            glob_quad.emit(Q_GOTO,"-1");
            update_nextinstr();                                 //update the next instruction number
        }
        ;

equality_expression
        :relational_expression 
        {
            $$ = $1;                //equality of two expressions
        }
        |equality_expression EQUALS relational_expression 
        {
            compareExpType(&$1,&$3);                             //check compatibility of data types of 2 expr
            $$.type = new type_n(tp_bool);                  //set the boolean data type
            $$.truelist = makelist(next_instr);             //create a truelist
            $$.falselist = makelist(next_instr+1);          //create a falselist
            glob_quad.emit(IF_EQUAL,$1.loc->name,$3.loc->name,"-1");
            glob_quad.emit(Q_GOTO,"-1");
            update_nextinstr();                             //update the next instruction number
        }
        |equality_expression NOT_EQUALS relational_expression 
        {
            compareExpType(&$1,&$3);                             //check compatibility of data types of 2 expr
            $$.type = new type_n(tp_bool);                  //set boolean datatype
            $$.truelist = makelist(next_instr);             //create a truelist
            $$.falselist = makelist(next_instr+1);          //create a falselist
            glob_quad.emit(IF_NOT_EQUAL,$1.loc->name,$3.loc->name,"-1");
            glob_quad.emit(Q_GOTO,"-1");
            update_nextinstr();                             //update the next instruction number
        }
        ;

AND_expression 
        :equality_expression 
        {
            $$ = $1;                //equality of expressions
        }
        |AND_expression '&' equality_expression 
        {
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_LOG_AND,$1.loc->name,$3.loc->name,$$.loc->name);
            update_nextinstr();    //update the next instruction number
        }
        ;

exclusive_OR_expression
        :AND_expression 
        {
            $$ = $1;                //equality of expressions
        }
        |exclusive_OR_expression '^' AND_expression 
        {
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_XOR,$1.loc->name,$3.loc->name,$$.loc->name);
            update_nextinstr();     //update the next instruction number
        }
        ;

inclusive_OR_expression
        :exclusive_OR_expression 
        {   
            $$ = $1;                //equality of two expressions
        }
        |inclusive_OR_expression '|' exclusive_OR_expression 
        {
            $$.loc = curr_st->gentemp($1.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_LOG_OR,$1.loc->name,$3.loc->name,$$.loc->name);
            update_nextinstr();    //update the next instruction number
        }
        ;

logical_AND_expression
        :inclusive_OR_expression 
        {
            $$ = $1;             //equality of two expressions
        }
        |logical_AND_expression LOGICAL_AND M inclusive_OR_expression 
        {
            if($1.type->basetp != tp_bool)
                conv2Bool(&$1);
            if($4.type->basetp != tp_bool)
                conv2Bool(&$4);
            backpatch($1.truelist,$3);
            $$.type = new type_n(tp_bool);
            $$.falselist = merge($1.falselist,$4.falselist);
            $$.truelist = $4.truelist;
            update_nextinstr(); //update the next instruction number
        }
        ;

logical_OR_expression
        :logical_AND_expression 
        {
            $$ = $1;            //equality of two expressions
        }
        |logical_OR_expression LOGICAL_OR M logical_AND_expression   
        {
            if($1.type->basetp != tp_bool)
                conv2Bool(&$1);
            if($4.type->basetp != tp_bool)
                conv2Bool(&$4); 
            backpatch($1.falselist,$3);
            $$.type = new type_n(tp_bool);
            $$.truelist = merge($1.truelist,$4.truelist);
            $$.falselist = $4.falselist;
            update_nextinstr(); //update the next instruction number
        }
        ;

/*It is assumed that type of expression and conditional expression are same*/
conditional_expression
        :logical_OR_expression 
        {
            $$ = $1;            //equality of two expressions
        }
        |logical_OR_expression N QUES M expression N COLON M conditional_expression 
        {
            $$.loc = curr_st->gentemp($5.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_ASSIGN,$9.loc->name,$$.loc->name);
            list* TEMP_LIST = makelist(next_instr);
            glob_quad.emit(Q_GOTO,"-1");
            backpatch($6,next_instr);
            glob_quad.emit(Q_ASSIGN,$5.loc->name,$$.loc->name);
            TEMP_LIST = merge(TEMP_LIST,makelist(next_instr));
            glob_quad.emit(Q_GOTO,"-1");
            backpatch($2,next_instr);
            conv2Bool(&$1);
            backpatch($1.truelist,$4);
            backpatch($1.falselist,$8);
            backpatch(TEMP_LIST,next_instr);
            update_nextinstr(); //update the next instruction number
        }
        ;

assignment_operator                 //various assignment operators
        :ASSIGN                                                     
        |MULTIPLY_ASSIGN                                         
        |DIVIDE_ASSIGN                                           |MODULO_ASSIGN                                           
        |ADD_ASSIGN                                              
        |SUBTRACT_ASSIGN                                         
        |BITWISE_LEFT_ASSIGN                                       
        |BITWISE_RIGHT_ASSIGN                                      
        |BITWISE_AND_ASSIGN                                              
        |XOR_ASSIGN                                              
        |BITWISE_OR_ASSIGN                                               
        ;

assignment_expression
        :conditional_expression 
        {
            $$ = $1;            //equality of two expressions
        }
        |unary_expression assignment_operator assignment_expression 
        {
            if($1.isPointer)
            {
                glob_quad.emit(Q_LDEREF,$3.loc->name,$1.loc->name);
            }
            compareExpType(&$1,&$3,true);
            if($1.arr != NULL)
            {
                glob_quad.emit(Q_LINDEX,$1.loc->name,$3.loc->name,$1.arr->name);
            }
            else if(!$1.isPointer)
                glob_quad.emit(Q_ASSIGN,$3.loc->name,$1.loc->name);
            $$.loc = curr_st->gentemp($3.type);
            $$.type = $$.loc->tp_n;
            glob_quad.emit(Q_ASSIGN,$3.loc->name,$$.loc->name);
            update_nextinstr();//update the next instruction number
        }
        ;

/*A constant value of this expression exists*/
constant_expression
        :conditional_expression 
        {
                $$ = $1;            //equality of two expressions
                update_nextinstr(); //update the next instruction number
        }
        ;

expression 
        :assignment_expression 
        {
            $$ = $1;            //equality of two expressions
            update_nextinstr(); //update the next instruction number
        }
        |expression ',' assignment_expression 
        {
            $$ = $3;            //equality of two expressions
            update_nextinstr(); //update the next instruction number
        }
        ;


// -------------------------------- 2. DECLARATIONS ------------------------------

declaration
        :declaration_specifiers init_declarator_list_opt SEMICOLON 
        {
            if($2.loc != NULL && $2.type != NULL && $2.type->basetp == tp_func)
            {
                //delete the current symbol table
                curr_st = new symtab();
                update_nextinstr();     //update the next instruction number    
            }
        }
        ;

init_declarator_list_opt
        :init_declarator_list 
        {
            if($1.type != NULL && $1.type->basetp == tp_func)
            {
                $$ = $1;                 //equality of two expressions
                update_nextinstr();      //update the next instruction number 
            }
        }
        |/*epsilon*/ 
        {
            $$.loc = NULL;      
            update_nextinstr();         //update the next instruction number 
        }
        ;

declaration_specifiers
        :storage_class_specifier declaration_specifiers_opt {}
        |type_specifier declaration_specifiers_opt               
        |type_qualifier declaration_specifiers_opt {}
        |function_specifier declaration_specifiers_opt {}
        ;

declaration_specifiers_opt
        :declaration_specifiers                                  
        |/*epsilon*/                                             
        ;

init_declarator_list
        :init_declarator 
        {
            /*Expecting only function declaration*/
            $$ = $1;
            update_nextinstr();         //update the next instruction number 
        }
        |init_declarator_list ',' init_declarator                
        ;

init_declarator
        :declarator 
        {
            if($1.type != NULL && $1.type->basetp == tp_func)
            {
                $$ = $1;
                update_nextinstr();         //update the next instruction number 
            }   
        }
        |declarator ASSIGN initializer 
        {
            //initializations of declarators
            if($3.type!=NULL)
            {
                if($3.type->basetp==tp_int)
                {
                    $1.loc->i_val.int_val= $3.loc->i_val.int_val;
                    $1.loc->isInitialized = true;
                    symdata *temp_ver=curr_st->search($1.loc->name);
                    if(temp_ver!=NULL)
                    {
                        temp_ver->i_val.int_val= $3.loc->i_val.int_val;
                        temp_ver->isInitialized = true;
                    }
                }
                else if($3.type->basetp==tp_char)
                {
                    $1.loc->i_val.char_val= $3.loc->i_val.char_val;
                    $1.loc->isInitialized = true;
                    symdata *temp_ver=curr_st->search($1.loc->name);
                    if(temp_ver!=NULL)
                    {
                        temp_ver->i_val.char_val= $3.loc->i_val.char_val;
                        temp_ver->isInitialized = true;
                     }
                }
            }
            glob_quad.emit(Q_ASSIGN,$3.loc->name,$1.loc->name);
            update_nextinstr();         //update the next instruction number 
        }
        ;

storage_class_specifier
        :EXTERN {}
        |STATIC {}
        ;

type_specifier
        :VOID 
        {
            glob_type = new type_n(tp_void);
            update_nextinstr();                 //update the next instruction number 
        }
        |CHAR 
        {
            glob_type = new type_n(tp_char);
            update_nextinstr();                 //update the next instruction number 
        }
        |SHORT {}
        |INT 
        {
            glob_type = new type_n(tp_int);
            update_nextinstr();                 //update the next instruction number 
        }
        |LONG {}
        |FLOAT {}
        |DOUBLE 
        {
            glob_type = new type_n(tp_double);
            update_nextinstr();                 //update the next instruction number 
        }
        ;

specifier_qualifier_list
        :type_specifier specifier_qualifier_list_opt {  }
        |type_qualifier specifier_qualifier_list_opt {  }
        ; 

specifier_qualifier_list_opt
        :specifier_qualifier_list   {   }
        |/*epsilon*/                {   }
        ;

identifier_opt
        :IDENTIFIER 
        {
            $$.loc  = curr_st->lookup(*$1.name);
            $$.type = new type_n(glob_type->basetp);
            update_nextinstr();                 //update the next instruction number 
        }
        |/*epsilon*/    {   }
        ;   

type_qualifier
        :CONST      {   }
        |RESTRICT   {   }
        |VOLATILE   {   }
        ;

function_specifier
        :INLINE     {   }
        ;

declarator 
        :pointer_opt direct_declarator 
        {
            if($1.type == NULL)
            {
                update_nextinstr();             //update the next instruction number 
            }
            else
            {
                if($2.loc->tp_n->basetp != tp_ptr)
                {
                    type_n * test = $1.type;
                    while(test->next != NULL)
                    {
                        test = test->next;
                    }
                    test->next = $2.loc->tp_n;
                    $2.loc->tp_n = $1.type;
                    update_nextinstr();         //update the next instruction number 
                }
            }

            if($2.type != NULL && $2.type->basetp == tp_func)
            {
                $$ = $2;
                update_nextinstr();            //update the next instruction number 
            }
            else
            {
                //its not a function
                $2.loc->size = $2.loc->tp_n->getSize();
                $2.loc->offset = curr_st->offset;
                curr_st->offset += $2.loc->size;
                $$ = $2;
                $$.type = $$.loc->tp_n;
                update_nextinstr();           //update the next instruction number 
            }
        }
        ;

pointer_opt
        :pointer 
        {   
            $$ = $1;                    //setting pointer value
            update_nextinstr();         //update the next instruction number 
        }
        |/*epsilon*/ 
        {
            $$.type = NULL;             //setting pointer value as NULL
            update_nextinstr();         //update the next instruction number 
        }
        ;

direct_declarator
        :IDENTIFIER 
        {
            $$.loc = curr_st->lookup(*$1.name); //check if identifier exists in current ST
            if($$.loc->var_type == "")
            {
                //Type initialization
                $$.loc->var_type = "local";
                $$.loc->tp_n = new type_n(glob_type->basetp);
            }
            $$.type = $$.loc->tp_n;
            update_nextinstr();             //update the next instruction number 
        }
        |ROUND_BRACKET_OPEN declarator ROUND_BRACKET_CLOSE 
        {
            $$ = $2;                        //assign declarator value
            update_nextinstr();             //update the next instruction number 
        }
        |direct_declarator SQUARE_BRACKET_OPEN type_qualifier_list_opt assignment_expression_opt SQUARE_BRACKET_CLOSE 
        {
            if($1.type->basetp == tp_arr)
            {
                /*if type is already an arr*/
                type_n * typ1 = $1.type,*typ = $1.type;
                typ1 = typ1->next;
                while(typ1->next != NULL)
                {
                    typ1 = typ1->next;
                    typ = typ->next;
                }
                typ->next = new type_n(tp_arr,$4.loc->i_val.int_val,typ1);
            }
            else
            {
                //add the type of array to list
                if($4.loc == NULL)
                    $1.type = new type_n(tp_arr,-1,$1.type);
                else
                    $1.type = new type_n(tp_arr,$4.loc->i_val.int_val,$1.type);
            }
            $$ = $1;
            $$.loc->tp_n = $$.type;
            update_nextinstr();
        }
        |direct_declarator SQUARE_BRACKET_OPEN STATIC type_qualifier_list_opt assignment_expression SQUARE_BRACKET_CLOSE     {   }
        |direct_declarator SQUARE_BRACKET_OPEN type_qualifier_list STATIC assignment_expression SQUARE_BRACKET_CLOSE                           {   }
        |direct_declarator SQUARE_BRACKET_OPEN type_qualifier_list_opt '*' SQUARE_BRACKET_CLOSE {    }
        |direct_declarator ROUND_BRACKET_OPEN parameter_type_list ROUND_BRACKET_CLOSE 
        {
            int params_no=curr_st->num_params;
            curr_st->num_params=0;
            int dec_params=0;
            int over_params=params_no;
            for(int i=curr_st->symbol_tab.size()-1;i>=0;i--)
            {
                update_nextinstr();             //update the next instruction number 
            }   
            for(int i=curr_st->symbol_tab.size()-1;i>=0;i--)
            {
                string detect=curr_st->symbol_tab[i]->name;
                if(over_params==0)
                {
                    break;
                }
                if(detect.size()==4)
                {
                    if(detect[0]=='t')
                    {
                        if('0'<=detect[1]&&detect[1]<='9')
                        {
                            if('0'<=detect[2]&&detect[2]<='9')
                            {
                                if('0'<=detect[3]&&detect[3]<='9')
                                    dec_params++;
                            }
                        }
                    }
                }
                else
                    over_params--;
                update_nextinstr();             //update the next instruction number 
            }
            params_no+=dec_params;
            int temp_i=curr_st->symbol_tab.size()-params_no;
            symdata * new_func = glob_st->search(curr_st->symbol_tab[temp_i-1]->name);
            if(new_func == NULL)
            {
                new_func = glob_st->lookup(curr_st->symbol_tab[temp_i-1]->name);
                update_nextinstr();
                $$.loc = curr_st->symbol_tab[temp_i-1];
                for(int i=0;i<(temp_i-1);i++)
                {
                    curr_st->symbol_tab[i]->ispresent=false;
                    if(curr_st->symbol_tab[i]->var_type=="local"||curr_st->symbol_tab[i]->var_type=="temp")
                    {
                        symdata *glob_var=glob_st->search(curr_st->symbol_tab[i]->name);
                        if(glob_var==NULL)
                        {
                            glob_var=glob_st->lookup(curr_st->symbol_tab[i]->name);
                            int t_size=curr_st->symbol_tab[i]->tp_n->getSize();
                            glob_var->offset=glob_st->offset;
                            glob_var->size=t_size;
                            glob_st->offset+=t_size;
                            glob_var->nest_tab=glob_st;
                            glob_var->var_type=curr_st->symbol_tab[i]->var_type;
                            glob_var->tp_n=curr_st->symbol_tab[i]->tp_n;
                            if(curr_st->symbol_tab[i]->isInitialized)
                            {
                                glob_var->isInitialized=curr_st->symbol_tab[i]->isInitialized;
                                glob_var->i_val=curr_st->symbol_tab[i]->i_val;
                                update_nextinstr();
                            }
                        }
                    }
                }
                if(new_func->var_type == "")
                {
                    // Declaration of the function for the first time
                    new_func->tp_n = duplicateType(curr_st->symbol_tab[temp_i-1]->tp_n);
                    new_func->var_type = "func";
                    new_func->isInitialized = false;
                    new_func->nest_tab = curr_st;
                    curr_st->name = curr_st->symbol_tab[temp_i-1]->name;
                    curr_st->symbol_tab[temp_i-1]->name = "retVal";
                    curr_st->symbol_tab[temp_i-1]->var_type = "return";
                    curr_st->symbol_tab[temp_i-1]->size = curr_st->symbol_tab[temp_i-1]->tp_n->getSize();
                    curr_st->symbol_tab[temp_i-1]->offset = 0;
                    curr_st->offset = 16;
                    int count=0;
                    for(int i=(curr_st->symbol_tab.size())-params_no;i<curr_st->symbol_tab.size();i++)
                    {
                        curr_st->symbol_tab[i]->var_type = "param";
                        curr_st->symbol_tab[i]->offset = count- curr_st->symbol_tab[i]->size;
                        count=count-curr_st->symbol_tab[i]->size;
                    }
                }
            }
            else
            {
                curr_st = new_func->nest_tab;
            }
            curr_st->start_quad = next_instr;
            $$.loc = new_func;
            $$.type = new type_n(tp_func);
            update_nextinstr();
        }
        |direct_declarator ROUND_BRACKET_OPEN identifier_list_opt ROUND_BRACKET_CLOSE 
        {
            int temp_i=curr_st->symbol_tab.size();
            symdata * new_func = glob_st->search(curr_st->symbol_tab[temp_i-1]->name);
            if(new_func == NULL)
            {
                new_func = glob_st->lookup(curr_st->symbol_tab[temp_i-1]->name);
                $$.loc = curr_st->symbol_tab[temp_i-1];
                for(int i=0;i<temp_i-1;i++)
                {
                    curr_st->symbol_tab[i]->ispresent=false;
                    if(curr_st->symbol_tab[i]->var_type=="local"||curr_st->symbol_tab[i]->var_type=="temp")
                    {
                        symdata *glob_var=glob_st->search(curr_st->symbol_tab[i]->name);
                        if(glob_var==NULL)
                        {
                            glob_var=glob_st->lookup(curr_st->symbol_tab[i]->name);
                            int t_size=curr_st->symbol_tab[i]->tp_n->getSize();
                            glob_var->offset=glob_st->offset;
                            glob_var->size=t_size;
                            glob_st->offset+=t_size;
                            glob_var->nest_tab=glob_st;
                            glob_var->var_type=curr_st->symbol_tab[i]->var_type;
                            glob_var->tp_n=curr_st->symbol_tab[i]->tp_n;
                            if(curr_st->symbol_tab[i]->isInitialized)
                            {
                                glob_var->isInitialized=curr_st->symbol_tab[i]->isInitialized;
                                glob_var->i_val=curr_st->symbol_tab[i]->i_val;
                            }
                        }
                    }
                }
                if(new_func->var_type == "")
                {
                    /*Function is being declared here for the first time*/
                    new_func->tp_n = duplicateType(curr_st->symbol_tab[temp_i-1]->tp_n);
                    update_nextinstr();
                    new_func->var_type = "func";
                    new_func->isInitialized = false;
                    new_func->nest_tab = curr_st;
                    /*Change the first element to retval and change the rest to param*/
                    curr_st->name = curr_st->symbol_tab[temp_i-1]->name;
                    curr_st->symbol_tab[temp_i-1]->name = "retVal";
                    curr_st->symbol_tab[temp_i-1]->var_type = "return";
                    curr_st->symbol_tab[temp_i-1]->size = curr_st->symbol_tab[0]->tp_n->getSize();
                    curr_st->symbol_tab[temp_i-1]->offset = 0;
                    curr_st->offset = 16;
                }
            }
            else
            {
                // Already declared function. Therefore drop the new table and connect current symbol table pointer to the previously created funciton symbol table
                curr_st = new_func->nest_tab;
            }
            curr_st->start_quad = next_instr;
            $$.loc = new_func;
            $$.type = new type_n(tp_func);
            update_nextinstr();
        }
        ;

type_qualifier_list_opt
        :type_qualifier_list    {   }
        |/*epsilon*/            {   }
        ;

assignment_expression_opt
        :assignment_expression 
        {
            $$ = $1;
            update_nextinstr();
        }
        |/*epsilon*/ 
        {
            $$.loc = NULL;
            update_nextinstr();
        }
        ;

identifier_list_opt
        :identifier_list                                         
        |/*epsilon*/                                             
        ;

pointer
        :'*' type_qualifier_list_opt 
        {
            $$.type = new type_n(tp_ptr);
            update_nextinstr();
        }
        |'*' type_qualifier_list_opt pointer 
        {
            $$.type = new type_n(tp_ptr,1,$3.type);
            update_nextinstr();
        }
        ;

type_qualifier_list
        :type_qualifier                     {   }
        |type_qualifier_list type_qualifier {   }
        ;

parameter_type_list
        :parameter_list                 {   }
        |parameter_list ',' ELLIPSIS    {   }
        ;

parameter_list
        :parameter_declaration 
        {
            (curr_st->num_params)++;     //increment the # of parameters
            update_nextinstr();         //update the next instruction number 
        }
        |parameter_list ',' parameter_declaration 
        {
            (curr_st->num_params)++;     //increment the # of parameters
            update_nextinstr();         //update the next instruction number 
        }
        ;

parameter_declaration
        :declaration_specifiers declarator 
        {
            /*The parameter is already added to the current Symbol Table*/
            update_nextinstr();         //update the next instruction number 
        }
        |declaration_specifiers {   }
        ;

identifier_list 
        :IDENTIFIER                                              
        |identifier_list ',' IDENTIFIER                          
        ;

type_name
        :specifier_qualifier_list                                
        ;

initializer
        :assignment_expression 
        {
            $$ = $1;
        }
        |CURLY_BRACKET_OPEN initializer_list CURLY_BRACKET_CLOSE       {   }
        |CURLY_BRACKET_OPEN initializer_list ',' CURLY_BRACKET_CLOSE   {   }
        ;

initializer_list
        :designation_opt initializer                             
        |initializer_list ',' designation_opt initializer        
        ;                                                                                                                           

designation_opt
        :designation                                             
        |/*Epslion*/


designation
        :designator_list ASSIGN                                     
        ;

designator_list
        :designator                                              
        |designator_list designator                              
        ;

designator
        :SQUARE_BRACKET_OPEN constant_expression SQUARE_BRACKET_CLOSE                             
        |DOT IDENTIFIER                 {   }
        ;


// -------------------------------- 3. STATEMENTS ------------------------------


statement
        :labeled_statement  {    }
        |compound_statement 
        {
            $$ = $1;                    //assignment of statement value
            update_nextinstr();         //update the next instruction number 
        }
        |expression_statement 
        {
            $$ = NULL;
            update_nextinstr();         //update the next instruction number
        }
        |selection_statement 
        {
            $$ = $1;
            update_nextinstr();         //update the next instruction number
        }
        |iteration_statement 
        {
            $$ = $1;
            update_nextinstr();         //update the next instruction number
        }
        |jump_statement 
        {
            $$ = $1;
            update_nextinstr();         //update the next instruction number
        }
        ;

labeled_statement
        :IDENTIFIER COLON statement               {   }
        |CASE constant_expression COLON statement {   }
        |DEFAULT COLON statement                  {   }
        ;

compound_statement
        :CURLY_BRACKET_OPEN block_item_list_opt CURLY_BRACKET_CLOSE 
        {
            $$ = $2;
            update_nextinstr();         //update the next instruction number
        }
        ;

block_item_list_opt
        :block_item_list 
        {
            $$ = $1;
            update_nextinstr();             //update the next instruction number
        }
        |/*Epslion*/ 
        {
            $$ = NULL;
            update_nextinstr();             //update the next instruction number
        }
        ;

block_item_list
        :block_item 
        {
            $$ = $1;
            update_nextinstr();             //update the next instruction number
        }
        |block_item_list M block_item 
        {
            backpatch($1,$2);
            $$ = $3;
            update_nextinstr();             //update the next instruction number
        }
        ;

block_item
        :declaration 
        {
            $$ = NULL;
            update_nextinstr();             //update the next instruction number
        }   
        |statement 
        {
            $$ = $1;
            update_nextinstr();             //update the next instruction number
        }
        ;

expression_statement
        :expression_opt SEMICOLON
        {
            $$ = $1;
            update_nextinstr();             //update the next instruction number
        }
        ;

expression_opt
        :expression 
        {
            $$ = $1;
            update_nextinstr();             //update the next instruction number
        }
        |/*Epslion*/ 
        {
            /*Initialize Expression to NULL*/
            $$.loc = NULL;
            update_nextinstr();             //update the next instruction number
        }
        ;

selection_statement
        :IF ROUND_BRACKET_OPEN expression N ROUND_BRACKET_CLOSE M statement N ELSE M statement 
        {
            /*N1 is used for falselist of expression, M1 is used for truelist of expression, N2 is used to prevent fall through, M2 is used for falselist of expression*/
            $7 = merge($7,$8);
            $11 = merge($11,makelist(next_instr));
            glob_quad.emit(Q_GOTO,"-1");
            backpatch($4,next_instr);
            conv2Bool(&$3);
            backpatch($3.truelist,$6);
            backpatch($3.falselist,$10);
            $$ = merge($7,$11);
            update_nextinstr();
        }
        |IF ROUND_BRACKET_OPEN expression N ROUND_BRACKET_CLOSE M statement %prec IF_CONFLICT
        {
            /*N is used for the falselist of expression to skip the block and M is used for truelist of expression*/
            $7 = merge($7,makelist(next_instr));
            glob_quad.emit(Q_GOTO,"-1");
            backpatch($4,next_instr);
            conv2Bool(&$3);
            backpatch($3.truelist,$6);
            $$ = merge($7,$3.falselist);
            update_nextinstr();
        }
        |SWITCH ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement {  }
        ;

iteration_statement
        :WHILE ROUND_BRACKET_OPEN M expression N ROUND_BRACKET_CLOSE M statement 
        {
            /*The first 'M' takes into consideration that the control will come again at the beginning of the condition checking.'N' here does the work of breaking condition i.e. it generate goto which wii be useful when we are exiting from while loop. Finally, the last 'M' is here to note the startinf statement that will be executed in every loop to populate the truelists of expression*/
            glob_quad.emit(Q_GOTO,$3);
            backpatch($8,$3);           /*S.nextlist to M1.instr*/
            backpatch($5,next_instr);    /*N1.nextlist to next_instr*/
            conv2Bool(&$4);
            backpatch($4.truelist,$7);
            $$ = $4.falselist;
            update_nextinstr();
        }
        |DO M statement  WHILE ROUND_BRACKET_OPEN M expression N ROUND_BRACKET_CLOSE SEMICOLON 
        {  
            /*M1 is used for coming back again to the statement as it stores the instruction which will be needed by the truelist of expression. M2 is neede as we have to again to check the condition which will be used to populate the nextlist of statements. Further N is used to prevent from fall through*/
            backpatch($8,next_instr);
            backpatch($3,$6);           /*S1.nextlist to M2.instr*/
            conv2Bool(&$7);
            backpatch($7.truelist,$2);  /*B.truelist to M1.instr*/
            $$ = $7.falselist;
            update_nextinstr();
        }
        |FOR ROUND_BRACKET_OPEN expression_opt SEMICOLON M expression_opt N SEMICOLON M expression_opt N ROUND_BRACKET_CLOSE M statement 
        {
            /*M1 is used for coming back to check the epression at every iteration. N1 is used  for generating the goto which will be used for exit conditions. M2 is used for nextlist of statement and N2 is used for jump to check the expression and M3 is used for the truelist of expression*/
            backpatch($11,$5);          /*N2.nextlist to M1.instr*/
            backpatch($14,$9);          /*S.nextlist to M2.instr*/
            glob_quad.emit(Q_GOTO,$9);
            backpatch($7,next_instr);    /*N1.nextlist to next_instr*/
            conv2Bool(&$6);
            backpatch($6.truelist,$13);
            $$ = $6.falselist;
            update_nextinstr();
        }
        |FOR ROUND_BRACKET_OPEN declaration expression_opt SEMICOLON expression_opt ROUND_BRACKET_CLOSE statement {}
        ;

jump_statement
        :GOTO IDENTIFIER SEMICOLON    {   }
        |CONTINUE SEMICOLON           {   }
        |BREAK SEMICOLON              {   }
        |RETURN expression_opt SEMICOLON 
        {
            if($2.loc == NULL)
                glob_quad.emit(RETURN_CODE);
            else
            {
                expresn * dummy = new expresn();
                dummy->loc = curr_st->symbol_tab[0];
                dummy->type = dummy->loc->tp_n;
                compareExpType(dummy,&$2,true);
                delete dummy;
                glob_quad.emit(RETURN_CODE,$2.loc->name);
            }
            $$ = NULL;
            update_nextinstr();
        }
        ;


// -------------------------------- 4. EXTERNAL DEFINITIONS  --------------------


translation_unit
        :external_declaration                                    
        |translation_unit external_declaration                   
        ;

external_declaration
        :function_definition                                     
        |declaration      
        {
            for(int i=0;i<curr_st->symbol_tab.size();i++)
            {
                if(curr_st->symbol_tab[i]->nest_tab==NULL)
                {
                    if(curr_st->symbol_tab[i]->var_type=="local"||curr_st->symbol_tab[i]->var_type=="temp")
                    {
                        symdata *glob_var=glob_st->search(curr_st->symbol_tab[i]->name);
                        if(glob_var==NULL)
                        {
                            glob_var=glob_st->lookup(curr_st->symbol_tab[i]->name);
                            int t_size=curr_st->symbol_tab[i]->tp_n->getSize();
                            glob_var->offset=glob_st->offset;              
                            glob_var->size=t_size;
                            glob_st->offset+=t_size;
                            glob_var->nest_tab=glob_st;
                            glob_var->var_type=curr_st->symbol_tab[i]->var_type;
                            glob_var->tp_n=curr_st->symbol_tab[i]->tp_n;
                            if(curr_st->symbol_tab[i]->isInitialized)
                            {
                                glob_var->isInitialized=curr_st->symbol_tab[i]->isInitialized;
                                glob_var->i_val=curr_st->symbol_tab[i]->i_val;
                            }
                        }
                    }
                }
            }
        }                                       
        ;

function_definition
        :declaration_specifiers declarator declaration_list_opt compound_statement 
        {
            symdata * func = glob_st->lookup($2.loc->name);
            func->nest_tab->symbol_tab[0]->tp_n = duplicateType(func->tp_n);
            func->nest_tab->symbol_tab[0]->name = "retVal";
            func->nest_tab->symbol_tab[0]->offset = 0;

            //If return type is pointer then change the offset
            if(func->nest_tab->symbol_tab[0]->tp_n->basetp == tp_ptr)
            {
                int diff = PTR_SIZE - func->nest_tab->symbol_tab[0]->size;
                func->nest_tab->symbol_tab[0]->size = PTR_SIZE;
                for(int i=1;i<func->nest_tab->symbol_tab.size();i++)
                {
                    func->nest_tab->symbol_tab[i]->offset += diff;
                }
            }
            int offset_size = 0;
            for(int i=0;i<func->nest_tab->symbol_tab.size();i++)
            {
                offset_size += func->nest_tab->symbol_tab[i]->size;
            }
            func->nest_tab->end_quad = next_instr-1;
            //Create a new Current Symbol Table
            curr_st = new symtab();
            update_nextinstr();             
        }
        ;

declaration_list_opt
        :declaration_list                                        
        |/*epsilon*/                                             
        ;

declaration_list
        :declaration                                             
        |declaration_list declaration                            
        ;

%%
// Called on error in case invalid input is obtained that cannot
// parsed by the parser generated by Bison
void yyerror(const char*s)
{
    printf("%s",s);
}
