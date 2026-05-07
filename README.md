# Gerenciamento de Dados Acadêmicos (SQL & Modelagem)


Este repositório contém o projeto de implementação de um Banco de Dados Relacional para o gerenciamento de uma faculdade, e foi idealizado por Fabio da Bóson Treinamentos (curso completo de Modelagem de Dados disponível em: https://www.youtube.com/watch?v=Q_KTYFgvu1s&list=PLucm8g_ezqNoNHU8tjVeHmRGBFnjDIlxD). O projeto percorre desde o levantamento de requisitos e regras de negócio até a implementação do modelo físico e população de dados.


## Cenário do Projeto


O objetivo é centralizar o controle de Alunos, Professores, Cursos, Disciplinas, Turmas e Histórico Escolar, garantindo a integridade dos dados e permitindo consultas complexas para análise de desempenho acadêmico.

Todas as regras de negócio estão contidas neste arquivo, acesse: https://docs.google.com/document/d/1eTyH5AyYKHkiXgnwDiTT2sGKIWiDjeGp/edit?usp=sharing&ouid=106429783053417088364&rtpof=true&sd=true


## Ferramentas


- Modelagem Conceitual e Lógica: brModelo

- SGBD: MySQL 8.0

- Interface: MySQL Workbench

- Linguagem: SQL (DDL para estrutura e DML para manipulação)


## Etapas de Desenvolvimento


### 1. Modelo Conceitual e Lógico:
   
O design seguiu as regras de normalização para evitar redundâncias, garantindo que relacionamentos N:N (Muitos para Muitos) fossem resolvidos através de tabelas associativas (como PROF_DISCIPLINA).

Veja o modelo conceitual (Sem aplicação das Formas Normais) em: https://drive.google.com/file/d/1JvIwLdcf6w69jqrsz24lkjsZ8oFbbQBx/view?usp=sharing

Veja o modelo lógico (Após a aplicação das Formas Normais) em: https://drive.google.com/file/d/1gHFfNvUwpeIh7jLSANEazDIoOf4y-xOZ/view?usp=sharing


### 2. Dicionário de Dados

No dicionário de dados é possível verificar a definição de tipos de dados. EX:

- RA (Registro Acadêmico): VARCHAR(8) como Chave Primária.

- Notas: DECIMAL(4) para precisão de cálculos.

Veja o completo dicionário em: https://docs.google.com/spreadsheets/d/11QZeib9sJ4lhIsjXpbQz3zKR_dthjbSY/edit?usp=sharing&ouid=106429783053417088364&rtpof=true&sd=true


### 3. Implementação Física (SQL)
   
O script automatizado realiza:

- Criação do Schema;

- Criação de tabelas respeitando a hierarquia de dependência;

- Inserção de dados de teste (população do banco);

Veja o arquivo do Projeto em SQL: https://drive.google.com/file/d/1MGgLbk7ucNP_jAD7KVGTqa5OopMqaNcq/view?usp=sharing


# Como Executar o Projeto


- Clone este repositório.

- Certifique-se de ter o MySQL Server instalado.

- Abra o MySQL Workbench e execute o arquivo script_final_faculdade.sql.

- O banco ProjetoBDFaculdade será criado e populado automaticamente.


# Exemplo de Consulta (Analytics)


Para validar os dados, observa-se o uso de queries de JOIN para extrair relatórios, como o que está logo abaixo, que lista alunos e seus respectivos professores:

   SQL
   SELECT A.Nome_Aluno, C.Nome_Curso, P.Nome_Professor
   FROM ALUNO A
   JOIN CURSO C ON A.Cod_Curso = C.Cod_Curso
   JOIN PROFESSOR P ON P.Cod_Departamento = C.Cod_Departamento;


# Autora


Danielli Arçari - Estudante de Ciência da Computação (UNINTER)
Foco em SQL, Python e Analytics Engineering.
