-- ============================================================
--  PROJETO: Banco de Dados para Gerenciamento de Faculdade
--  Autor   : Danielli Meilene Coutinho Arçari
--  SGBD    : MySQL 8.0
--  Adaptado ao Modelo Lógico
-- ============================================================

-- Criar Banco
DROP DATABASE IF EXISTS db_Faculdade;
CREATE DATABASE db_Faculdade;
USE db_Faculdade;

-- ============================================================
-- CRIAR TABELAS
-- ============================================================

CREATE TABLE Departamento (
    Cod_Departamento INT          PRIMARY KEY AUTO_INCREMENT,
    Nome_Departamento VARCHAR(20) NOT NULL
);

CREATE TABLE Professor (
    Cod_Professor       INT          PRIMARY KEY AUTO_INCREMENT,
    Nome_Professor      VARCHAR(20)  NOT NULL,
    Sobrenome_Professor VARCHAR(50)  NOT NULL,
    Status              BOOLEAN,
    Cod_Departamento    INT,
    CONSTRAINT fk_Professor_Departamento
        FOREIGN KEY (Cod_Departamento) REFERENCES Departamento (Cod_Departamento)
);

CREATE TABLE Curso (
    Cod_Curso        INT         PRIMARY KEY AUTO_INCREMENT,
    Nome_Curso       VARCHAR(30),
    Cod_Departamento INT,
    CONSTRAINT fk_Curso_Departamento
        FOREIGN KEY (Cod_Departamento) REFERENCES Departamento (Cod_Departamento)
);

CREATE TABLE Turma (
    Cod_Turma   INT         PRIMARY KEY AUTO_INCREMENT,
    Cod_Curso   INT,
    Periodo     VARCHAR(8),
    Num_Alunos  INT,
    Data_Inicio DATE,
    Data_Fim    DATE,
    CONSTRAINT fk_Turma_Curso
        FOREIGN KEY (Cod_Curso) REFERENCES Curso (Cod_Curso)
);

CREATE TABLE Disciplina (
    Cod_Disciplina        INT          PRIMARY KEY AUTO_INCREMENT,
    Cod_Departamento      INT          NOT NULL,
    Nome_Disciplina       VARCHAR(30),
    Descricao             VARCHAR(80),
    Num_Alunos            INT          NOT NULL,
    Carga_Horaria         INT          NOT NULL,
    CONSTRAINT fk_Disciplina_Departamento
        FOREIGN KEY (Cod_Departamento) REFERENCES Departamento (Cod_Departamento)
);

-- Tabela de auto-relacionamento de Disciplina (pré-requisito)
-- Representada como "Depende" no modelo lógico
CREATE TABLE Depende (
    fk_Disciplina_Cod_Disciplina_1 INT NOT NULL,  -- Disciplina que depende
    fk_Disciplina_Cod_Disciplina_2 INT NOT NULL,  -- Disciplina da qual depende
    PRIMARY KEY (fk_Disciplina_Cod_Disciplina_1, fk_Disciplina_Cod_Disciplina_2),
    CONSTRAINT fk_Depende_Disciplina_1
        FOREIGN KEY (fk_Disciplina_Cod_Disciplina_1) REFERENCES Disciplina (Cod_Disciplina),
    CONSTRAINT fk_Depende_Disciplina_2
        FOREIGN KEY (fk_Disciplina_Cod_Disciplina_2) REFERENCES Disciplina (Cod_Disciplina)
);

-- Nome atualizado: Prof_Disciplina -> Professor_Disciplina
CREATE TABLE Professor_Disciplina (
    Cod_Professor  INT NOT NULL,
    Cod_Disciplina INT NOT NULL,
    PRIMARY KEY (Cod_Professor, Cod_Disciplina),
    CONSTRAINT fk_ProfDisci_Professor
        FOREIGN KEY (Cod_Professor)  REFERENCES Professor  (Cod_Professor),
    CONSTRAINT fk_ProfDisci_Disciplina
        FOREIGN KEY (Cod_Disciplina) REFERENCES Disciplina (Cod_Disciplina)
);

CREATE TABLE Curso_Disciplina (
    Cod_Curso      INT NOT NULL,
    Cod_Disciplina INT NOT NULL,
    PRIMARY KEY (Cod_Curso, Cod_Disciplina),
    CONSTRAINT fk_CursoDisci_Curso
        FOREIGN KEY (Cod_Curso)      REFERENCES Curso      (Cod_Curso),
    CONSTRAINT fk_CursoDisci_Disciplina
        FOREIGN KEY (Cod_Disciplina) REFERENCES Disciplina (Cod_Disciplina)
);

-- Novas tabelas de localização (Estado → Cidade → Bairro)
CREATE TABLE Estado_Aluno (
    Cod_Estado  INT          PRIMARY KEY AUTO_INCREMENT,
    Nome_Estado VARCHAR(50)  NOT NULL,
    UF          CHAR(2)      NOT NULL
);

CREATE TABLE Cidade_Aluno (
    Cod_Cidade  INT         PRIMARY KEY AUTO_INCREMENT,
    Nome_Cidade VARCHAR(50) NOT NULL,
    Cod_Estado  INT         NOT NULL,
    CONSTRAINT fk_Cidade_Estado
        FOREIGN KEY (Cod_Estado) REFERENCES Estado_Aluno (Cod_Estado)
);

CREATE TABLE Bairro_Aluno (
    Cod_Bairro  INT         PRIMARY KEY AUTO_INCREMENT,
    Cod_Cidade  INT         NOT NULL,
    Nome_Bairro VARCHAR(50) NOT NULL,
    CONSTRAINT fk_Bairro_Cidade
        FOREIGN KEY (Cod_Cidade) REFERENCES Cidade_Aluno (Cod_Cidade)
);

CREATE TABLE Aluno (
    RA              INT         PRIMARY KEY AUTO_INCREMENT,
    Nome_Aluno      VARCHAR(20) NOT NULL,
    Sobrenome_Aluno VARCHAR(20) NOT NULL,
    Status          BOOLEAN     NOT NULL,
    Sexo            CHAR(1),
    CPF             CHAR(11)    NOT NULL,
    Cod_Curso       INT,
    Cod_Turma       INT,
    Nome_Pai        VARCHAR(50) NOT NULL,
    Nome_Mae        VARCHAR(50) NOT NULL,
    Email           VARCHAR(50) NOT NULL,
    Whatsapp        VARCHAR(20) NOT NULL,
    CONSTRAINT fk_Aluno_Turma
        FOREIGN KEY (Cod_Turma) REFERENCES Turma (Cod_Turma),
    CONSTRAINT fk_Aluno_Curso
        FOREIGN KEY (Cod_Curso) REFERENCES Curso (Cod_Curso)
);

-- Nome atualizado: Aluno_Disc -> Aluno_Disciplina
CREATE TABLE Aluno_Disciplina (
    RA_Aluno       INT NOT NULL,
    Cod_Disciplina INT NOT NULL,
    PRIMARY KEY (RA_Aluno, Cod_Disciplina),
    CONSTRAINT fk_AlunoDisci_Aluno
        FOREIGN KEY (RA_Aluno)       REFERENCES Aluno      (RA),
    CONSTRAINT fk_AlunoDisci_Disciplina
        FOREIGN KEY (Cod_Disciplina) REFERENCES Disciplina (Cod_Disciplina)
);

CREATE TABLE Historico (
    Cod_Historico INT  PRIMARY KEY AUTO_INCREMENT,
    RA_Aluno      INT  NOT NULL,
    Data_Inicio   DATE NOT NULL,
    Data_Final    DATE,
    CONSTRAINT fk_Historico_Aluno
        FOREIGN KEY (RA_Aluno) REFERENCES Aluno (RA)
);

-- Nome atualizado: Disc_Hist -> Disciplina_Historico
CREATE TABLE Disciplina_Historico (
    Cod_Historico    INT NOT NULL,
    Cod_Disciplina   INT NOT NULL,
    Nota_Media_Final DECIMAL(4,2),
    Frequencia       INT,
    PRIMARY KEY (Cod_Historico, Cod_Disciplina),
    CONSTRAINT fk_DiscHist_Historico
        FOREIGN KEY (Cod_Historico)  REFERENCES Historico  (Cod_Historico),
    CONSTRAINT fk_DiscHist_Disciplina
        FOREIGN KEY (Cod_Disciplina) REFERENCES Disciplina (Cod_Disciplina)
);

CREATE TABLE Tipo_Telefone (
    Cod_Tipo_Telefone INT         PRIMARY KEY AUTO_INCREMENT,
    Tipo_Telefone     VARCHAR(8)
);

CREATE TABLE Telefones_Aluno (
    Cod_Telefones_Aluno INT         PRIMARY KEY AUTO_INCREMENT,
    RA_Aluno            INT         NOT NULL,
    Cod_Tipo_Telefone   INT         NOT NULL,
    Num_Telefone        VARCHAR(20) NOT NULL,
    CONSTRAINT fk_TelAluno_Aluno
        FOREIGN KEY (RA_Aluno)          REFERENCES Aluno         (RA),
    CONSTRAINT fk_TelAluno_TipoTel
        FOREIGN KEY (Cod_Tipo_Telefone) REFERENCES Tipo_Telefone (Cod_Tipo_Telefone)
);

CREATE TABLE Tipo_Logradouro (
    Cod_Tipo_Logradouro INT         PRIMARY KEY AUTO_INCREMENT,
    Tipo_Logradouro     VARCHAR(11)
);

-- Endereco_Aluno agora inclui Cod_Bairro (FK -> Bairro_Aluno)
CREATE TABLE Endereco_Aluno (
    Cod_Endereco_Aluno  INT         PRIMARY KEY AUTO_INCREMENT,
    RA_Aluno            INT         NOT NULL,
    Cod_Tipo_Logradouro INT         NOT NULL,
    Nome_Rua            VARCHAR(50) NOT NULL,
    Num_Rua             INT         NOT NULL,
    Complemento         VARCHAR(20) NULL,
    CEP                 CHAR(8)     NOT NULL,
    Cod_Bairro          INT         NOT NULL,
    CONSTRAINT fk_EndAluno_Aluno
        FOREIGN KEY (RA_Aluno)            REFERENCES Aluno           (RA),
    CONSTRAINT fk_EndAluno_TipoLogr
        FOREIGN KEY (Cod_Tipo_Logradouro) REFERENCES Tipo_Logradouro (Cod_Tipo_Logradouro),
    CONSTRAINT fk_EndAluno_Bairro
        FOREIGN KEY (Cod_Bairro)          REFERENCES Bairro_Aluno    (Cod_Bairro)
);

-- ============================================================
-- CARGA DE DADOS PARA TESTES
-- ============================================================

INSERT INTO Departamento (Nome_Departamento) VALUES
    ('Ciências Humanas'),
    ('Matemática'),
    ('Biológicas'),
    ('Estágio');

INSERT INTO Professor (Nome_Professor, Sobrenome_Professor, Status, Cod_Departamento) VALUES
    ('Fábio',  'dos Reis',  FALSE, 2),
    ('Sophie', 'Allemand',  TRUE,  1),
    ('Monica', 'Barroso',   TRUE,  3);

INSERT INTO Curso (Nome_Curso, Cod_Departamento) VALUES
    ('Matemática',        2),
    ('Psicologia',        1),
    ('Análise de Sistemas', 2),
    ('Biologia',          3),
    ('História',          1),
    ('Engenharia',        2);

INSERT INTO Turma (Cod_Curso, Periodo, Num_Alunos, Data_Inicio, Data_Fim) VALUES
    (2, 'Manhã',  20, '2016-05-12', '2017-10-15'),
    (1, 'Noite',  10, '2014-05-12', '2020-03-05'),
    (3, 'Tarde',  15, '2012-05-12', '2014-05-10');

INSERT INTO Disciplina (Nome_Disciplina, Cod_Departamento, Carga_Horaria, Descricao, Num_Alunos) VALUES
    ('Raciocínio Lógico',    2, 1200, 'Desenvolver o raciocínio lógico',         50),
    ('Psicologia Cognitiva', 1, 1400, 'Entender o funcionamento do aprendizado',  30),
    ('Programação em C',     2, 1200, 'Aprender uma linguagem de programação',    20),
    ('Eletrônica Digital',   2,  300, 'Funcionamento de circuitos digitais',      30);

INSERT INTO Aluno (Nome_Aluno, Sobrenome_Aluno, CPF, Status, Cod_Turma, Sexo, Cod_Curso, Nome_Pai, Nome_Mae, Email, Whatsapp) VALUES
    ('Marcos',    'Aurelio Martins',    '14278914536', TRUE, 2, 'M', 3, 'Marcio Aurelio',   'Maria Aparecida',    'marcosaurelio@gmail.com',    '946231249'),
    ('Gabriel',   'Fernando de Almeida','14470954536', TRUE, 1, 'M', 1, 'Adão Almeida',     'Fernanda Almeida',   'gabrielalmeida@yahoo.com',   '941741247'),
    ('Beatriz',   'Sonia Meneguel',     '1520984537',  TRUE, 3, 'F', 3, 'Samuel Meneguel',  'Gabriella Meneguel', 'batrizmene@hotmail.com',     '945781412'),
    ('Jorge',     'Soares',             '14223651562', TRUE, 3, 'M', 4, 'João Soares',      'Maria Richter',      'jorgesoares@gmail.com',      '925637857'),
    ('Ana Paula', 'Ferretti',           '32968914522', TRUE, 3, 'F', 5, 'Marcio Ferretti',  'Ana Hoffbahn',       'anapaulaferretti@hotmail.com','974267423'),
    ('Mônica',    'Yamaguti',           '32988914510', TRUE, 2, 'F', 6, 'Wilson Oliveira',  'Fernanda Yamaguti',  'monyamaguti@outlook.com',    '932619560');

INSERT INTO Aluno_Disciplina (RA_Aluno, Cod_Disciplina) VALUES
    (3, 1), (1, 2), (2, 3), (4, 3), (5, 4), (6, 1);

INSERT INTO Curso_Disciplina (Cod_Curso, Cod_Disciplina) VALUES
    (1, 1), (2, 2), (3, 3), (6, 4);

INSERT INTO Professor_Disciplina (Cod_Professor, Cod_Disciplina) VALUES
    (2, 1), (1, 2), (3, 3), (2, 4);

INSERT INTO Historico (RA_Aluno, Data_Inicio, Data_Final) VALUES
    (2, '2016-05-12', '2017-10-15'),
    (3, '2014-05-12', '2020-03-05'),
    (1, '2010-05-12', '2012-05-10');

INSERT INTO Tipo_Logradouro (Tipo_Logradouro) VALUES
    ('Rua'), ('Avenida'), ('Alameda'), ('Travessa');

-- Dados para as 3 novas tabelas de localização
INSERT INTO Estado_Aluno (Nome_Estado, UF) VALUES
    ('São Paulo', 'SP');

INSERT INTO Cidade_Aluno (Nome_Cidade, Cod_Estado) VALUES
    ('São Paulo', 1);

INSERT INTO Bairro_Aluno (Nome_Bairro, Cod_Cidade) VALUES
    ('Jardim das Giestas', 1),
    ('Lorena',             1),
    ('Cursino',            1),
    ('Heras',              1),
    ('Santos',             1),
    ('Matão',              1);

INSERT INTO Endereco_Aluno (RA_Aluno, Cod_Tipo_Logradouro, Nome_Rua, Num_Rua, Complemento, CEP,      Cod_Bairro) VALUES
    (2, 1, 'das Giestas',  255,  'Casa 02', '02854000', 1),
    (3, 3, 'Lorena',        10,  'Apto 15', '02945000', 2),
    (1, 2, 'do Cursino',  1248,  '',        '08510400', 3),
    (4, 1, 'das Heras',    495,  '',        '03563142', 4),
    (5, 3, 'Santos',      1856,  '',        '04523963', 5),
    (6, 4, 'Matão',        206,  '',        '04213650', 6);

-- ============================================================
-- CONSULTAS PARA TESTES
-- ============================================================

SELECT * FROM Aluno;

SELECT * FROM Disciplina;

SELECT * FROM Curso;  -- corrigido: era "Cursos"

SELECT A.Nome_Aluno, A.Sobrenome_Aluno, C.Nome_Curso
FROM Curso C
INNER JOIN Aluno A ON C.Cod_Curso = A.Cod_Curso;

-- ============================================================
-- TESTES FINAIS E CORREÇÕES
-- ============================================================

-- Alterar campo Nota da tabela Disciplina_Historico para FLOAT
ALTER TABLE Disciplina_Historico
MODIFY COLUMN Nota_Media_Final FLOAT(4,2);

-- Inserir dados de disciplinas e notas no histórico
INSERT INTO Disciplina_Historico (Cod_Historico, Cod_Disciplina, Nota_Media_Final, Frequencia)
VALUES
    (1, 2, 7,   6),  -- Marcos  - Psicologia Cognitiva (cod 2)
    (2, 3, 8.5, 2),  -- Gabriel - Programação em C (cod 3)
    (3, 1, 6.8, 8);  -- Beatriz - Raciocínio Lógico (cod 1)

-- RAs, Nomes e Sobrenomes dos Alunos, Nomes dos Cursos e Períodos das Turmas
SELECT A.RA, A.Nome_Aluno, A.Sobrenome_Aluno, T.Periodo, C.Nome_Curso
FROM Aluno A
INNER JOIN Curso C ON C.Cod_Curso = A.Cod_Curso
INNER JOIN Turma T ON T.Cod_Turma = A.Cod_Turma
ORDER BY A.Nome_Aluno;

-- Todas as disciplinas cursadas por um aluno, com suas respectivas notas
-- Aluno: RA 3 (Beatriz)
SELECT A.Nome_Aluno, A.Sobrenome_Aluno, D.Nome_Disciplina, DH.Nota_Media_Final
FROM Aluno A
INNER JOIN Aluno_Disciplina AD  ON A.RA              = AD.RA_Aluno
INNER JOIN Disciplina D         ON D.Cod_Disciplina  = AD.Cod_Disciplina
INNER JOIN Historico H          ON A.RA              = H.RA_Aluno
INNER JOIN Disciplina_Historico DH ON H.Cod_Historico = DH.Cod_Historico
WHERE A.RA = 3;

-- Nomes e sobrenomes dos professores e disciplinas que ministram
SELECT CONCAT(P.Nome_Professor, ' ', P.Sobrenome_Professor) AS Docente;