# Gerenciamento de Dados Acadêmicos — Projeto de Banco de Dados Relacional

Este projeto nasceu como parte da formação em Ciência da Computação na UNINTER e tem como objetivo modelar, do zero, um banco de dados relacional para o gerenciamento de uma faculdade. Ele cobre todas as etapas do processo: levantamento de requisitos, modelagem conceitual e lógica, dicionário de dados, implementação física em MySQL e consultas analíticas.

A metodologia seguida é baseada no curso de Modelagem de Dados de [Fábio Boson (Bóson Treinamentos)](https://www.youtube.com/watch?v=Q_KTYFgvu1s&list=PLucm8g_ezqNoNHU8tjVeHmRGBFnjDIlxD), a quem são dados os devidos créditos.

---

## Sobre o Projeto

O banco centraliza o controle de Alunos, Professores, Cursos, Disciplinas, Turmas e Histórico Escolar, garantindo integridade referencial e suporte a consultas de desempenho acadêmico.

---

## Estrutura do Repositório

```
ProjetoBDFaculdade
 ┣ BD_ProjetoFaculdade.sql                   <- Script principal (DDL + DML + Queries)
 ┣ DicionarioDeDados_ProjetoBDFaculdade.xlsx <- Dicionário de dados completo
 ┣ RegrasDeNegocio_ProjetoBDFaculdade.docx   <- Levantamento de requisitos e regras de negócio
 ┣ Lógico_ProjetoBDFaculdade.png             <- Diagrama do Modelo Lógico
 ┣ Lógico_ProjetoBDFaculdade.brM3            <- Arquivo do Modelo Lógico (brModelo)
 ┗ ProjetoBDFaculdade.brM3                   <- Arquivo do Modelo Conceitual (brModelo)
```

---

## Etapas de Desenvolvimento

### 1. Levantamento de Requisitos e Regras de Negócio

Antes de escrever qualquer linha de SQL, o primeiro passo foi entender como a faculdade funciona. As principais regras mapeadas foram:

- Um aluno só pode estar matriculado em um curso por vez
- Um aluno pode se matricular em no máximo 9 disciplinas por semestre
- O aluno só pode ser reprovado no máximo 3 vezes na mesma disciplina
- Cada disciplina comporta no máximo 30 alunos por turma
- Cada professor leciona no máximo 4 disciplinas e está vinculado a um departamento
- Professores podem ser cadastrados mesmo sem lecionar disciplinas
- Uma disciplina pode ter pré-requisitos (auto-relacionamento)
- O Histórico Escolar registra nota final, frequência e período de cada disciplina cursada

O documento completo está em `RegrasDeNegocio_ProjetoBDFaculdade.docx`.

---

### 2. Modelagem Conceitual e Lógica

As entidades identificadas foram: Aluno, Professor, Disciplina, Curso, Departamento, Turma e Histórico.

Os relacionamentos muitos-para-muitos foram resolvidos com tabelas associativas:

| Tabela Associativa   | Entidades envolvidas                         |
|----------------------|----------------------------------------------|
| Professor_Disciplina | Professor e Disciplina                       |
| Curso_Disciplina     | Curso e Disciplina                           |
| Aluno_Disciplina     | Aluno e Disciplina (matrícula semestral)     |
| Disciplina_Historico | Histórico e Disciplina (notas e frequência)  |
| Depende              | Disciplina e Disciplina (pré-requisito)      |

O modelo lógico foi normalizado até a 3ª Forma Normal (3FN), eliminando dependências parciais e transitivas. O diagrama está em `Lógico_ProjetoBDFaculdade.png`.

---

### 3. Dicionário de Dados

O dicionário define o tipo, tamanho, restrições e descrição de cada atributo. Alguns exemplos:

| Atributo         | Tipo       | Restrição          | Descrição                          |
|------------------|------------|--------------------|------------------------------------|
| RA               | INT        | PK, AUTO_INCREMENT | Registro Acadêmico do aluno        |
| CPF              | CHAR(11)   | NOT NULL           | CPF do aluno (somente dígitos)     |
| Nota_Media_Final | FLOAT(4,2) | NOT NULL           | Nota final da disciplina (0 a 10)  |
| Frequencia       | INT        | NOT NULL           | Frequência em número de aulas      |
| Status           | BOOLEAN    | NOT NULL           | Status ativo do aluno ou professor |

O dicionário completo está em `DicionarioDeDados_ProjetoBDFaculdade.xlsx`.

---

### 4. Implementação Física (MySQL 8.0)

O script `BD_ProjetoFaculdade.sql` executa as seguintes etapas em ordem:

1. Recriação do schema com `DROP DATABASE IF EXISTS` seguido de `CREATE DATABASE`, o que permite reexecutar o script quantas vezes for necessário sem erros
2. Criação das tabelas respeitando a hierarquia de dependências das chaves estrangeiras
3. Definição das constraints de integridade: `FOREIGN KEY`, `NOT NULL`, `PRIMARY KEY` e `AUTO_INCREMENT`
4. Inserção dos dados de teste: 6 alunos, 3 professores, 4 disciplinas e 6 cursos
5. Consultas analíticas com JOINs para relatórios de desempenho acadêmico

Vale destacar que algumas regras de negócio não são expressáveis apenas com `CHECK` e precisariam de triggers ou validação na camada de aplicação, como o limite de 9 disciplinas por aluno por semestre e o limite de 3 reprovações na mesma disciplina.

---

### 5. Tabelas do Banco de Dados

O banco conta com 18 tabelas no total, organizadas da seguinte forma:

Cadastro principal: `Departamento`, `Professor`, `Curso`, `Turma`, `Disciplina`, `Aluno`

Relacionamentos N:N: `Professor_Disciplina`, `Curso_Disciplina`, `Aluno_Disciplina`, `Disciplina_Historico`, `Depende`

Histórico escolar: `Historico`

Contato e endereço: `Tipo_Telefone`, `Telefones_Aluno`, `Tipo_Logradouro`, `Endereco_Aluno`

Localização: `Estado_Aluno`, `Cidade_Aluno`, `Bairro_Aluno`

---

## Exemplos de Consultas

**Notas e frequência por aluno:**
```sql
SELECT
    A.RA,
    CONCAT(A.Nome_Aluno, ' ', A.Sobrenome_Aluno) AS Aluno,
    D.Nome_Disciplina,
    DH.Nota_Media_Final,
    DH.Frequencia
FROM Aluno A
JOIN Historico            H  ON A.RA              = H.RA_Aluno
JOIN Disciplina_Historico DH ON H.Cod_Historico   = DH.Cod_Historico
JOIN Disciplina           D  ON DH.Cod_Disciplina = D.Cod_Disciplina
ORDER BY A.RA, D.Nome_Disciplina;
```

**Professores e as disciplinas que lecionam:**
```sql
SELECT
    CONCAT(P.Nome_Professor, ' ', P.Sobrenome_Professor) AS Professor,
    D.Nome_Disciplina
FROM Professor P
JOIN Professor_Disciplina PD ON P.Cod_Professor   = PD.Cod_Professor
JOIN Disciplina           D  ON PD.Cod_Disciplina = D.Cod_Disciplina
ORDER BY Professor;
```

**Alunos com seus cursos e períodos de turma:**
```sql
SELECT
    A.RA,
    A.Nome_Aluno,
    A.Sobrenome_Aluno,
    T.Periodo,
    C.Nome_Curso
FROM Aluno A
INNER JOIN Curso C ON C.Cod_Curso = A.Cod_Curso
INNER JOIN Turma T ON T.Cod_Turma = A.Cod_Turma
ORDER BY A.Nome_Aluno;
```

**Média geral por aluno:**
```sql
SELECT
    CONCAT(A.Nome_Aluno, ' ', A.Sobrenome_Aluno) AS Aluno,
    ROUND(AVG(DH.Nota_Media_Final), 2) AS Media_Geral,
    ROUND(AVG(DH.Frequencia), 2)       AS Frequencia_Media
FROM Aluno A
JOIN Historico            H  ON A.RA            = H.RA_Aluno
JOIN Disciplina_Historico DH ON H.Cod_Historico = DH.Cod_Historico
GROUP BY A.RA, Aluno
ORDER BY Media_Geral DESC;
```

---

## Ferramentas Utilizadas

| Ferramenta      | Finalidade                                     |
|-----------------|------------------------------------------------|
| brModelo        | Modelagem conceitual e lógica                  |
| MySQL 8.0       | Sistema gerenciador de banco de dados          |
| MySQL Workbench | Interface de execução e visualização           |
| SQL             | DDL (estrutura), DML (dados) e DQL (consultas) |

---

## Como Executar

```bash
# 1. Certifique-se de ter o MySQL Server 8.0 ou superior instalado
# 2. Clone este repositório
git clone https://github.com/seu-usuario/ProjetoBDFaculdade.git

# 3. Execute via terminal:
mysql -u root -p < BD_ProjetoFaculdade.sql
```

Ou, se preferir, abra o arquivo no MySQL Workbench e pressione `Ctrl + Enter` para rodar tudo de uma vez. O banco `db_Faculdade` será criado e populado automaticamente. Como o script começa com `DROP DATABASE IF EXISTS`, ele pode ser reexecutado sem problemas.

---

## Autora

**Danielli Meilene Coutinho Arçari** 

Estudante de Ciência da Computação na UNINTER, com interesse em SQL, Python e Analytics Engineering.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/seu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/seu-usuario)
