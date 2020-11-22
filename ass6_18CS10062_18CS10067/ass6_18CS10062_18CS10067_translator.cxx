#include "ass6_18CS10062_18CS10067_translator.h"
#include "y.tab.h"
#include<sstream>
#include<string>
#include<iostream>

long long int instr_ctr;	// count of instr (used for sanity check)
bool debug_on;			// bool for printing debug output

using namespace std;

type_n *glob_type;
symtab *glob_st =new symtab();
symtab *curr_st = new symtab();
quad_arr glob_quad;

vector <string> vs;
vector <string> cs;
vector <string> strings_label;

int next_instr;
int temp_count = 0;

// data type sizes
int INT_SIZE = 4;
int PTR_SIZE = 8;
int CHAR_SIZE = 1;
int BOOL_SIZE = 1;
int DOUBLE_SIZE = 8;

type_n::type_n(types t, int sz, type_n *n)
{
	basetp=t;	
	size=sz;
	next=n;
}

int type_n::getSize()
{
	if(this==NULL)
		return 0;
	//return the size of the array by calling the recursive function 
	//here we are not checking for null as if it will reach the final type it will enter the below conditions
	switch((*this).basetp){
		case tp_arr:
			return (((*this).size)*((*this).next->getSize()));
		
		case tp_void:
			return 0;
		
		case tp_int:
			return INT_SIZE;
		
		case tp_double:
			return DOUBLE_SIZE;
		
		case tp_bool:
			return BOOL_SIZE;
		
		case tp_char:
			return CHAR_SIZE;
		
		case tp_ptr:	
			return PTR_SIZE;
	}
}

types type_n::getBasetp()
{
	if(this!=NULL)
		return (*this).basetp;	
	else
		return tp_void;	
}

void type_n::printSize()
{
	printf("%d\n",size);
}

void type_n::print()
{
	switch(basetp){
		case tp_void:
			printf("Void");
			break;

		case tp_bool:
			printf("Bool");
			break;
		
		case tp_int:
			printf("Int");
			break;
		
		case tp_char:
			printf("Char");
			break;
		
		case tp_double:
			printf("Double");
			break;
		
		case tp_ptr:
			printf("ptr(");
			if((*this).next!=NULL)
				(*this).next->print();
			printf(")");
			break;

		case tp_arr:
			printf("array(%d,",size);
			if((*this).next!=NULL)
				(*this).next->print();
				printf(")");
			break;

		case tp_func:
			printf("Function()");
			break;

		default:
			printf("TYPE NOT FOUND\n");
			exit(-1);
	}
}

array::array(string s,int size,types t)
{
	(*this).tp=t;
	(*this).bsize=size;
	(*this).base_arr=s;
	(*this).dimension_size=1;
}

void array::addindex(int i)
{
	(*this).dimension_size=(*this).dimension_size+1;
	(*this).dims.push_back(i);
}

void funct::print()
{
	printf("Funct(");	
	int i;

	for(i=0;i<typelist.size();i++)
	{
		if(i!=0)
			printf(",");	
		printf("%d ",typelist[i]);
	}
	printf(")");
}

funct::funct(vector<types> typlist)
{
	typelist = typlist;	
}

// constructor for symdata
symdata::symdata(string n)
{
	name = n;
	size = 0;
	tp_n = NULL;
	offset = -1;
	var_type = "";
	isInitialized = false;
	isFunction = false;
	isArray = false;
	ispresent = true;
	arr = NULL;
	fun = NULL;
	nest_tab = NULL;
	isdone = false;
	isptrarr = false;
	isGlobal = false;
}

symtab::symtab()
{	
	name = "";	
	offset = 0;
	num_params = 0;
}

symtab::~symtab()
{
	int i=0;
	for(;i<symbol_tab.size();i++)
	{
		type_n *p1=(*symbol_tab[i]).tp_n;
		type_n *p2;
		
		while(true)
		{
			if(p1 == NULL)
				break;
			
			p2=p1;
			p1=(*p1).next;
			delete p2;
		}
	}
}

int symtab::findg(string n)
{
	for(int i=0; i<vs.size(); i++)
	{	
		if(vs[i] == n)
			return 1;
	}
	
	for(int i=0; i<cs.size(); i++)
	{	
		if(cs[i] == n)
			return 2;
	}	
	return 0;
}

type_n *duplicateType(type_n *t)
{
	/*Duplicates the input type and returns the pointer to the newly created type*/
	if(t == NULL) 
		return t;
	
	type_n *ret = new type_n((*t).basetp);
	
	(*ret).size = (*t).size;
	(*ret).basetp = (*t).basetp;
	
	(*ret).next = duplicateType((*t).next);
	
	return ret;
}

symdata* symtab::lookup(string n)
{
	for(int i = 0; i<symbol_tab.size(); i++)
	{
		if((*symbol_tab[i]).name == n)
			return symbol_tab[i];
	}
	
	symdata *temp_o=new symdata(n);
	(*temp_o).i_val.int_val=0;
	symbol_tab.push_back(temp_o);
	return symbol_tab[symbol_tab.size()-1];
}

symdata* symtab::lookup_2(string n)
{
	for(int i = 0; i<symbol_tab.size(); i++)
	{
		if(symbol_tab[i]->name == n)
			return symbol_tab[i];
	}
	
	for(int i = 0; i<(*glob_st).symbol_tab.size(); i++)
	{
		if((*glob_st).symbol_tab[i]->name == n)		
			return (*glob_st).symbol_tab[i];
	}
	
	symdata *temp_o=new symdata(n);
	(*temp_o).i_val.int_val=0;
	symbol_tab.push_back(temp_o);
	
	return symbol_tab[symbol_tab.size()-1];
}

symdata* symtab::search(string n)
{
	for(int i = 0; i<symbol_tab.size();i++)
	{
		if((*symbol_tab[i]).name==n && symbol_tab[i]->ispresent)		
			return (symbol_tab[i]);
	}
	
	return NULL;
}

symdata* symtab::gentemp(type_n *type)
{
	char c[10];
	sprintf(c, "t%03d", temp_count);
	temp_count++;
	symdata *temp=lookup(c);
	int temp_sz;
	
	if(type == NULL)
		temp_sz = 0;
	else
	{
		switch((*type).basetp){
			case tp_void:
				temp_sz = 0;
				break;
			
			case tp_int:
				temp_sz = INT_SIZE;
				break;
			
			case tp_double:
				temp_sz = DOUBLE_SIZE;
				break;

			case tp_bool:
				temp_sz = BOOL_SIZE;
				break;

			case tp_char:
				temp_sz = CHAR_SIZE;
				break;

			case tp_ptr:
				temp_sz = PTR_SIZE;
				break;

			case tp_arr:
				temp_sz = (*type).getSize();
				break;
		
			default:
				printf("TYPE NOT FOUND\n");
				exit(-1);
		}
	}
	
	(*temp).size=temp_sz;
	(*temp).var_type="temp";
	(*temp).tp_n=type;
	(*temp).offset=(*this).offset;
	(*this).offset=(*this).offset+((*temp).size);
	
	return temp;
}

void symtab::update(symdata *sym, type_n *type, basic_val initval, symtab *next)
{
	(*sym).tp_n=duplicateType(type);
	(*sym).i_val=initval;
	(*sym).nest_tab=next;
	int temp_sz;
	
	if((*sym).tp_n==NULL)
		temp_sz = 0;
	else
	{
		switch(((*sym).tp_n)->basetp){
			case tp_void:
				temp_sz = 0;
				break;

			case tp_int:
				temp_sz = INT_SIZE;
				break;

			case tp_double:
				temp_sz = DOUBLE_SIZE;
				break;

			case tp_bool:
				temp_sz = BOOL_SIZE;
				break;

			case tp_char:
				temp_sz = CHAR_SIZE;
				break;

			case tp_ptr:
				temp_sz = PTR_SIZE;
				break;

			case tp_arr:
				temp_sz = (*sym).tp_n->getSize();
		
			default:
				printf("TYPE NOT FOUND\n");
				exit(-1);
		}
	}
	
	(*sym).size = temp_sz;
	(*sym).offset = (*this).offset;
	(*this).offset = (*this).offset+((*sym).size);
	(*sym).isInitialized = false;
}

void symtab::print()
{
	printf("____________________________________________ %s ____________________________________________\n",name.c_str());
	printf("Offset = %d\nStart Quad Index = %d\nEnd Quad Index =  %d\n",offset,start_quad,end_quad);
	printf("Name\tValue\tvar_type\tsize\tOffset\tType\n\n");
    
    for(int i = 0; i<(symbol_tab).size(); i++)
    {	
        if(symbol_tab[i]->ispresent==false)
        	continue;
        
        symdata * t = symbol_tab[i];
        
        printf("%s\t",symbol_tab[i]->name.c_str()); 
        if((*t).isInitialized)
        {
        	if(((*t).tp_n)->basetp == tp_char) 
        		printf("%c\t",((*t).i_val).char_val);
        	else if(((*t).tp_n)->basetp == tp_int) 
        		printf("%d\t",((*t).i_val).int_val);
        	else if(((*t).tp_n)->basetp == tp_double) 
        		printf("%.3lf\t",((*t).i_val).double_val);
       	 	else printf("----\t"); 	
      	}

      	else
      		printf("null\t");
      	
        printf("%s",(*t).var_type.c_str());
        printf("\t\t%d\t%d\t",(*t).size,(*t).offset);
        
		if((*t).var_type == "func")
			printf("ptr-to-St( %s )",(*t).nest_tab->name.c_str());
		
		if((*t).tp_n != NULL)
			((*t).tp_n)->print();
		printf("\n");
	}
	
	printf("\n");
	printf("____________________________________________________________________________________________\n");
}
list* makelist(int i)
{
	list *temp = (list*)malloc(sizeof(list));
	(*temp).index=i;
	(*temp).next=NULL;
	return temp;
}
list* merge(list *lt1,list *lt2)
{
	list *temp = (list*)malloc(sizeof(list));
	list *p1=temp;
	int flag=0;
	list *l1=lt1;
	list *l2=lt2;
	
	while(l1!=NULL)
	{
		flag=1;
		(*p1).index=(*l1).index;
		
		if((*l1).next!=NULL)
		{
			(*p1).next=(list*)malloc(sizeof(list));
			p1=(*p1).next;
		}
		
		l1=(*l1).next;
	}

	while(l2!=NULL)
	{
		if(flag==1)
		{
			(*p1).next=(list*)malloc(sizeof(list));	
			p1=(*p1).next;
			flag=0;
		}
		(*p1).index=l2->index;
		if(l2->next!=NULL)
		{
			(*p1).next=(list*)malloc(sizeof(list));
			p1=(*p1).next;	
		}
		l2=l2->next;
	}
	(*p1).next=NULL;
	
	return temp;
}

quad::quad(opcode opc, string a1, string a2, string rs)
{
	(*this).op = opc;
	(*this).arg1 = a1;
	(*this).result = rs;
	(*this).arg2 = a2;
}

void quad::print_arg()
{
	printf("\t%s\t=\t%s\top\t%s\t",result.c_str(), arg1.c_str(), arg2.c_str());
}

quad_arr::quad_arr()
{
	next_instr = 0;	
}

void quad_arr::emit(opcode opc, string arg1, string arg2, string result)
{
	if(result.size()!=0)
	{		
		quad new_elem(opc,arg1,arg2,result);	
		arr.push_back(new_elem);
	}
	else if(arg2.size()!=0)
	{
		quad new_elem(opc,arg1,"",arg2);	
		arr.push_back(new_elem);
	}
	else if(arg1.size()!=0)
	{
		quad new_elem(opc,"","",arg1);	
		arr.push_back(new_elem);
	}
	else
	{
		quad new_elem(opc,"","","");	
		arr.push_back(new_elem);
	}
	next_instr++;
}

void quad_arr::emit2(opcode opc,string arg1, string arg2, string result)
{
	if(result.size() == 0)
	{	
		quad new_elem(opc, arg1, arg2, "");	
		arr.push_back(new_elem);
	}
}

void quad_arr::emit(opcode opc, int val, string operand)
{
	char String[20];	
	sprintf(String, "%d", val);
	if(operand.size()==0)
	{
		quad new_quad(opc, "", "", String);	
		arr.push_back(new_quad);
	}
	else
	{
		quad new_quad(opc, String, "", operand);	
		arr.push_back(new_quad);
	}
	next_instr++;
}

void quad_arr::emit(opcode opc, double val, string operand)
{
	char String[20];
	sprintf(String, "%lf", val);
	if(operand.size()==0)
	{
		quad new_quad(opc, "", "", String);	
		arr.push_back(new_quad);
	}
	else
	{
		quad new_quad(opc, String, "", operand);	
		arr.push_back(new_quad);
	}
	next_instr++;
}

void quad_arr::emit(opcode opc, char val, string operand)
{
	char String[20];
	sprintf(String, "'%c'", val);
	
	if(operand.size()==0)
	{
		quad new_quad(opc, "", "", String);	
		arr.push_back(new_quad);
	}

	else
	{	
		quad new_quad(opc, String, "", operand);	
		arr.push_back(new_quad);
	}
	next_instr++;
}

void quad_arr::print()
{
	opcode op;
	string arg1, arg2, result;
	
	for(int i=0;i<next_instr;i++)
	{
		op=arr[i].op;
		arg1=arr[i].arg1;
		arg2=arr[i].arg2;
		result=arr[i].result;
		
		printf("%3d : ",i);
		
		if(Q_PLUS<=op && op<=Q_NOT_EQUAL)
	    {
	        printf("%s",result.c_str());
	        printf("\t=\t");
	        printf("%s",arg1.c_str());
	        printf(" ");
	        
			switch(op){
				case Q_PLUS:
					printf("+");
					break;

				case Q_MINUS:
					printf("-");
					break;

				case Q_MULT:
					printf("*");
					break;

				case Q_DIVIDE:
					printf("/");
					break;
			
				case Q_MODULO:
					printf("%%");
					break;

				case Q_LEFT_OP:
					printf("<<");
					break;

				case Q_RIGHT_OP:
					printf(">>");
					break;

				case Q_XOR:
					printf("^");
					break;

				case Q_AND:
					printf("&");
					break;

				case Q_OR:
					printf("|");
					break;

				case Q_LOG_AND:
					printf("&&");
					break;

				case Q_LOG_OR:
					printf("||");
					break;

				case Q_LESS:
					printf("<");
					break;

				case Q_LESS_OR_EQUAL:
					printf("<=");
					break;

				case Q_GREATER_OR_EQUAL:
					printf(">=");
					break;

				case Q_GREATER:
					printf(">");
					break;

				case Q_EQUAL:
					printf("==");
					break;

				case Q_NOT_EQUAL:
					printf("!=");
					break;
			}        
	        printf(" ");
	       	printf("%s\n",arg2.c_str());  	
	    }

	    else if(Q_UNARY_MINUS<=op && op<=Q_ASSIGN)
	    {
	        printf("%s",result.c_str());
	        printf("\t=\t");
	        
			switch(op){
				case Q_UNARY_MINUS:
					printf("-");
					break;
				
				case Q_UNARY_PLUS:
					printf("+"); 
					break;
				
				case Q_COMPLEMENT:
					printf("~");
					break;

				case Q_NOT:
					printf("!");
					break;
			}
	        printf("%s\n",arg1.c_str());
	    }

	    else if(op == Q_GOTO)
	    {
	    	printf("goto ");
	    	printf("%s\n",result.c_str());
	    }
	    
		else if(IF_EQUAL<=op && op<=IF_GREATER_OR_EQUAL)
	    {
	        printf("if  ");printf("%s",arg1.c_str());printf(" ");
            //Conditional Jump
			switch(op){
				case IF_LESS:
					printf("<"); 
					break;
				
				case IF_GREATER:
					printf(">");
					break;

				case IF_LESS_OR_EQUAL:
					printf("<=");
					break;

				case IF_GREATER_OR_EQUAL:
					printf(">=");
					break;

				case IF_EQUAL:
					printf("==");
					break;

				case IF_NOT_EQUAL:
					printf("!="); 
					break;

				case IF_EXPRESSION:
					printf("!= 0"); 
					break;

				case IF_NOT_EXPRESSION:
					printf("== 0"); 
					break;

				default:
					printf("OPCODE NOT FOUND\n");
					exit(-1);
			}
			printf("%s",arg2.c_str());
	        printf("\tgoto ");
	        printf("%s\n",result.c_str());            
	    }

	    else if(CHAR2INT<=op && op<=DOUBLE2INT)
	    {
	        printf("%s",result.c_str());printf("\t=\t");
            // Type conversion
			switch(op){
				case CHAR2INT:
					printf(" Char2Int(");
            		printf("%s",arg1.c_str());printf(")\n"); 
					break;
				
				case CHAR2DOUBLE:
					printf(" Char2Int(");
            		printf("%s",arg1.c_str());printf(")\n");
					break;

				case INT2CHAR:
					printf(" Int2Char(");
					printf("%s",arg1.c_str());
					printf(")\n");
					break;

				case DOUBLE2CHAR:
					printf(" Double2Char(");
					printf("%s",arg1.c_str());
					printf(")\n");
					break;

				case INT2DOUBLE:
					printf(" Int2Double(");
					printf("%s",arg1.c_str());
					printf(")\n");
					break;

				case DOUBLE2INT:
					printf(" Double2Int(");
					printf("%s",arg1.c_str());
					printf(")\n");
					break; 

				default:
					printf("OPCODE NOT FOUND\n");
					exit(-1);
			}
	    }

		else
		{
			switch(op){
				case PARAM:
					printf("param\t");printf("%s\n",result.c_str());
					break;

				case Q_CALL:
					if(!result.c_str())
						printf("call %s, %s\n", arg1.c_str(), arg2.c_str());
					else if(result.size()==0)
						printf("call %s, %s\n", arg1.c_str(), arg2.c_str());
					else
						printf("%s\t=\tcall %s, %s\n", result.c_str(), arg1.c_str(), arg2.c_str()); 
					break;

				case RETURN_CODE:
					printf("return\t");
	        		printf("%s\n",result.c_str());	
					break;

				case Q_RINDEX:
					printf("%s\t=\t%s[%s]\n", result.c_str(), arg1.c_str(), arg2.c_str());
					break;

				case Q_LINDEX:
				printf("%s[%s]\t=\t%s\n", result.c_str(), arg1.c_str(), arg2.c_str());
					break;
			
				case Q_LDEREF:
				 	printf("*%s\t=\t%s\n", result.c_str(), arg1.c_str());
					break;

				case Q_RDEREF:
					printf("%s\t=\t* %s\n", result.c_str(), arg1.c_str());
					break;
			
				case Q_ADDR:
					printf("%s\t=\t& %s\n", result.c_str(), arg1.c_str());		
					break;
			
				default:
					printf("OPCODE NOT FOUND\n");
					exit(-1);
			}
		}
	}
}

// function for backpatching the dangling GOTOs
void backpatch(list *l,int i)
{
	list *l1 = l;
	list *l2;
	char str[10];
	sprintf(str, "%d", i);
	
	while(l1 != NULL)
	{
		glob_quad.arr[(*l1).index].result = str;	
		l2 = l1;
		l1 = (*l1).next;
		free(l2);
	}
}

void compareExpType(expresn *e1, expresn *e2, bool isAssign)
{
	types type1, type2;
	if(e1->type==NULL)
	{
		e1->type = duplicateType((*e2).type);
	}

	else if((*e2).type==NULL)
	{	
		(*e2).type = duplicateType(e1->type);
	}
	
	type1=((*e1).type)->basetp;
	type2=((*e2).type)->basetp;
	
	if(type1==type2)
	{
		return;
	}

	if(!isAssign)
	{
		if(type1>type2)
		{
			
			symdata *temp = (*curr_st).gentemp((*e1).type);
			
			if(type1 == tp_int && type2 == tp_char)
				glob_quad.emit(CHAR2INT, (*e2).loc->name, (*temp).name);
			else if(type1 == tp_double && type2 == tp_int)
				glob_quad.emit(INT2DOUBLE,(*e2).loc->name, (*temp).name);
			(*e2).loc = temp;
			
			(*e2).type = (*temp).tp_n;
			
		}
		else
		{
			
			symdata *temp = (*curr_st).gentemp((*e2).type);
			
			if(type2 == tp_int && type1 == tp_char)
				glob_quad.emit(CHAR2INT, e1->loc->name, (*temp).name);
			else if(type2 == tp_double && type1 == tp_int)
				glob_quad.emit(INT2DOUBLE, e1->loc->name, (*temp).name);	
			
			e1->loc = temp;			
			e1->type = (*temp).tp_n;
		}		
	}

	else
	{		
		symdata *temp = (*curr_st).gentemp(e1->type);
		if(type1 == tp_int && type2 == tp_double)
			glob_quad.emit(DOUBLE2INT, (*e2).loc->name, (*temp).name);
		else if(type1 == tp_double && type2 == tp_int)
			glob_quad.emit(INT2DOUBLE, (*e2).loc->name, (*temp).name);
		else if(type1 == tp_char && type2 == tp_int)
			glob_quad.emit(INT2CHAR, (*e2).loc->name, (*temp).name);
		else if(type1 == tp_int && type2 == tp_char)
			glob_quad.emit(CHAR2INT, (*e2).loc->name, (*temp).name);
		else
		{
			printf("%s %s Types compatibility not defined\n",e1->loc->name.c_str(),(*e2).loc->name.c_str());	
			exit(-1);
		}

		(*e2).loc = temp;
		(*e2).type = (*temp).tp_n;
	}
}

void print_list(list *root)
{
	int flg = 0;
	while(root != NULL)
	{
		printf("%d ",root->index);
		flg = 1;
		root=root->next;
	}
	
	if(flg == 0)
		printf("Empty List\n");
	else
		printf("\n");
}

void conv2Bool(expresn *e)
{
	if(((*e).type)->basetp != tp_bool)
	{
		((*e).type) = new type_n(tp_bool);	
		(*e).falselist = makelist(next_instr);
		glob_quad.emit(IF_EQUAL,(*e).loc->name,"0","-1");
		(*e).truelist = makelist(next_instr);
		glob_quad.emit(Q_GOTO,-1);		
	}
}

void update_nextinstr()
{
	instr_ctr++;
	if(debug_on==1)
	{
		cout<<"Current Line Number:"<<instr_ctr<<endl;
		cout<<"Press [ENTER] to continue:";
		cin.get();
	}
}

void debug()
{
	if(debug_on == 1)
		cout<<instr_ctr<<endl;	
}

int main()
{
	instr_ctr = 0;   // count of instr (used for sanity check)
	debug_on = 0;       // debugging is off
	symdata *temp_printi = new symdata("printInt");
	(*temp_printi).tp_n = new type_n(tp_int);
	(*temp_printi).var_type = "func";
	(*temp_printi).nest_tab = glob_st;
	(*glob_st).symbol_tab.push_back(temp_printi);
	
	symdata *temp_readi = new symdata("readInt");
	temp_readi->tp_n = new type_n(tp_int);
	temp_readi->var_type = "func";
	temp_readi->nest_tab = glob_st;
	(*glob_st).symbol_tab.push_back(temp_readi);
	
	symdata *temp_prints = new symdata("printStr");
	(*temp_prints).tp_n = new type_n(tp_int);
	(*temp_prints).var_type = "func";
	(*temp_prints).nest_tab = glob_st;
	(*glob_st).symbol_tab.push_back(temp_prints);
	
	yyparse();

	(*glob_st).name="Global";
	printf("_________________________________________________________________________________");
	printf("\nGenerated Quads for the program\n");

	glob_quad.print();
	printf("_________________________________________________________________________________\n");
	printf("Symbol table Maintained For the Given Program\n");
	
	(*glob_st).print();	
	set<string> setty;
	setty.insert("Global");
	printf("_________________________________________________________________________________\n");
	
	FILE *fp;
	fp = fopen("output.s","w");
	fprintf(fp,"\t.file\t\"output.s\"\n");
	
	for (int i = 0; i < strings_label.size(); ++i)
		fprintf(fp,"\n.STR%d:\t.string %s",i,strings_label[i].c_str());	
	
	set<string> setty_1;
	(*glob_st).mark_labels();
	(*glob_st).global_variables(fp);
	setty_1.insert("Global");
	int count_l=0;
	
	for (int i = 0; i < (*glob_st).symbol_tab.size(); ++i)
	{
		if((((*glob_st).symbol_tab[i])->nest_tab)!=NULL)
		{
			if(setty_1.find((((*glob_st).symbol_tab[i])->nest_tab)->name)==setty_1.end())
			{
				(*glob_st).symbol_tab[i]->nest_tab->assign_offset();
				(*glob_st).symbol_tab[i]->nest_tab->print();
				(*glob_st).symbol_tab[i]->nest_tab->function_prologue(fp,count_l);
				(*glob_st).symbol_tab[i]->nest_tab->function_restore(fp);
				(*glob_st).symbol_tab[i]->nest_tab->gen_internal_code(fp,count_l);
				
				setty_1.insert((((*glob_st).symbol_tab[i])->nest_tab)->name);
				(*glob_st).symbol_tab[i]->nest_tab->function_epilogue(fp,count_l,count_l);
				count_l++;
			}
		}
	}
	
	fprintf(fp,"\n");
	return 0;
}