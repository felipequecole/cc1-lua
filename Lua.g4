grammar Lua;

//Foi usado EBFN nas regras da linguagem.


@members {
    public static String grupo= "<619515, 619485, 619540>";
}

//Definição de nome: o nome deve iniciar obrigatoriamente com uma letra, depois pode conter letras, '_' e numeros
Nome : [a-zA-Z] [a-zA-Z0-9_]* ;

//Definição de numero: decimais, sem sinal, com dígitos antes e depois do ponto decimal opcionais
Numero: [0-9][0-9]* ('.' [0-9]+)?;

//Definição de cadeia: versões curtas, sem sequência de escape, quebras de linha não permitidas,
//delimitadas por aspas duplas ou simples
Cadeia:  '"' ~('\n' | '\r' | '"')* '"' |  '\'' ~('\n' | '\r' | '\'')* '\'';

// Ignora tabulações, returns e quebras de linha
WS : [ \t\r\n]+ -> skip;

//Ignora comentarios, comentarios na mesma linha
Comentario: '--' ~('\n')* '\n' -> skip;

//Regra lexica para reconhecimento de chamada de metodos
NomeAtributo: Nome ('.' Nome)+;

//definição de um programa
programa : trecho;

//definição de trecho
trecho : (comando (';')?)* (ultimocomando (';')?)?;

//definição de bloco
bloco : trecho;

//Comandos da linguagem
comando :   listavar '=' listaexp |
            callfuncao |
            'do' bloco 'end' |
            'while' exp 'do' bloco 'end' |
            'repeat' bloco 'until' exp |
            'if' exp 'then' bloco ('elseif' exp 'then' bloco)* ('else' bloco)? 'end' |
            'for' var '=' exp ',' exp (',' exp)? 'do' bloco 'end' |
            'for' listavar 'in' listaexp 'do' bloco 'end' |
            'function' nomedafuncao corpodafuncao |
            'local function' nomedafuncao corpodafuncao |
            'local' listadenomes ('=' listaexp)?;

//comando de natureza finalizadora
ultimocomando : 'return' (listaexp)? | 'break';

//definição do nome da função com chamadas para adição na tabela de simbolos
nomedafuncao : Nome {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.FUNCAO);} |
                NomeAtributo {TabelaDeSimbolos.adicionarSimbolo($NomeAtributo.text, Tipo.FUNCAO);};

//listas de variaveis separadas por virgula
listavar : var (',' var)*;

//definição das 3 variaveis presentes na linguagem Lua. Variáveis globais, variáveis locais e campos de tabelas
var :   Nome {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.VARIAVEL);}|
        Nome ('[' exp ']')+ {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.VARIAVEL);}|
        NomeAtributo {TabelaDeSimbolos.adicionarSimbolo($NomeAtributo.text, Tipo.VARIAVEL);};

// regra utilizada para salvar na tabela de simbolos
nome: Nome {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.VARIAVEL);};

//tipos de expressões
expprefixo :    var |
                callfuncao |
                '(' exp ')';

//chamada de funções (com "( )" ou " : ")
chamadadefuncao :   (args)+ |
                    (':' args)+;

//Listas de nomes, separados por virgula
listadenomes : nome (',' nome)*;

//Lista de expressões separadas por virgula
listaexp : (exp ',')* exp;

//expressões
exp : 'nil' | 'false' | 'true' | Numero | Cadeia | '...' |
expprefixo | construtortabela | exp opbin exp | opunaria exp;

// regra para chamadas de funcao e procedimentos
callfuncao: nomedafuncao chamadadefuncao;
//argumentos
args : '(' (listaexp)? ')' | construtortabela | Cadeia;
corpodafuncao : '(' (listapar)? ')' bloco 'end';

listapar : listadenomes (',' '...')? | '...';

//definição de construtor tabela
construtortabela : '{' (listadecampos)? '}';

//listas de campos, com separador de campos
listadecampos : campo (separadordecampos campo)* (separadordecampos)?;

//definição de campo
campo : '[' exp ']' '=' exp | Nome '=' exp | exp;

//separação de campos
separadordecampos : ',' | ';';

//Operadores binarios reservados
opbin : '+' | '-' | '*' | '/' | '^' | '%' | '..' |
'<' | '<=' | '>' | '>=' | '==' | '~=' |
'and' | 'or';

//Operadores unarios reservados
opunaria : '-' | 'not' | '#';