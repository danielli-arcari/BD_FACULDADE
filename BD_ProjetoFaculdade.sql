-- ============================================================
--  PROJETO: Banco de Dados para Gerenciamento de Faculdade
--  Autor   : Danielli Arçari
--  SGBD    : MySQL 8.0
-- ============================================================

-- 1. LIMPEZA E CRIAÇÃO DO SCHEMA
DROP DATABASE IF EXISTS ProjetoBDFaculdade;
CREATE DATABASE ProjetoBDFaculdade CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ProjetoBDFaculdade;

-- ============================================================
-- 2. CRIAÇÃO DAS TABELAS (ORDEM HIERÁRQUICA DE DEPENDÊNCIA)
-- ============================================================

CREATE TABLE DEPARTAMENTO (
    Cod_Departamento INT          PRIMARY KEY,
    Nome_Departamento VARCHAR(40) NOT NULL
);

CREATE TABLE PROFESSOR (
    Cod_Professor       INT         PRIMARY KEY,
    Nome_Professor      VARCHAR(40) NOT NULL,
    Sobrenome_Professor VARCHAR(40) NOT NULL,
    Status_Ativo        BOOLEAN     NOT NULL DEFAULT TRUE,
    Cod_Departamento    INT         NOT NULL,
    CONSTRAINT FK_PROF_DEPT FOREIGN KEY (Cod_Departamento)
        REFERENCES DEPARTAMENTO(Cod_Departamento)
);

CREATE TABLE CURSO (
    Cod_Curso        INT         PRIMARY KEY,
    Nome_Curso       VARCHAR(40) NOT NULL,
    Cod_Departamento INT         NOT NULL,
    CONSTRAINT FK_CURSO_DEPT FOREIGN KEY (Cod_Departamento)
        REFERENCES DEPARTAMENTO(Cod_Departamento)
);

CREATE TABLE DISCIPLINA (
    Cod_Disciplina   INT          PRIMARY KEY,
    Nome_Disciplina  VARCHAR(30)  NOT NULL,
    Descricao        VARCHAR(200),
    Carga_Horaria    INT          NOT NULL,
    -- RN: cada disciplina terá no máximo 30 alunos por turma
    Num_Alunos       INT          NOT NULL CHECK (Num_Alunos <= 30),
    Cod_Departamento INT          NOT NULL,
    CONSTRAINT FK_DISC_DEPT FOREIGN KEY (Cod_Departamento)
        REFERENCES DEPARTAMENTO(Cod_Departamento)
);

-- Pré-requisito de disciplina (auto-relacionamento — RN: "Disciplina depende de Disciplina")
CREATE TABLE DISC_PREREQ (
    Cod_Disciplina     INT NOT NULL,
    Cod_Prereq         INT NOT NULL,
    PRIMARY KEY (Cod_Disciplina, Cod_Prereq),
    CONSTRAINT FK_PREREQ_DISC  FOREIGN KEY (Cod_Disciplina) REFERENCES DISCIPLINA(Cod_Disciplina),
    CONSTRAINT FK_PREREQ_PRE   FOREIGN KEY (Cod_Prereq)     REFERENCES DISCIPLINA(Cod_Disciplina)
);

CREATE TABLE TURMA (
    Cod_Turma   INT         PRIMARY KEY,
    Periodo     VARCHAR(10) NOT NULL,
    Num_Alunos  INT         NOT NULL,
    Data_Inicio DATE        NOT NULL,
    Data_Fim    DATE        NOT NULL,
    Cod_Curso   INT         NOT NULL,
    CONSTRAINT FK_TURMA_CURSO FOREIGN KEY (Cod_Curso)
        REFERENCES CURSO(Cod_Curso),
    CONSTRAINT CHK_TURMA_DATAS CHECK (Data_Fim > Data_Inicio)
);

-- ============================================================
-- NOTA SOBRE O TIPO DO RA:
--   O modelo lógico (brModelo) gerou RA_Aluno como INTEGER,
--   mas VARCHAR(8) é a escolha correta para preservar zeros
--   à esquerda (ex.: "00230001") e por semântica: RA é um
--   identificador, não um valor numérico. Mantém-se VARCHAR(8).
-- ============================================================
CREATE TABLE ALUNO (
    RA               VARCHAR(8)  PRIMARY KEY,
    Nome_Aluno       VARCHAR(25) NOT NULL,
    Sobrenome_Aluno  VARCHAR(40) NOT NULL,
    -- CPF no formato "000.000.000-00" → 14 caracteres (corrigido: dicionário indicava 40, desnecessário)
    CPF              VARCHAR(14) NOT NULL UNIQUE,
    Status_Matricula VARCHAR(1)  NOT NULL
        COMMENT 'M=Matriculado, T=Trancado, F=Formado, C=Cancelado',
    Sexo             VARCHAR(1)  NOT NULL,
    Filiacao         VARCHAR(80),
    Endereco         VARCHAR(100),
    Cod_Turma        INT         NOT NULL,
    Cod_Curso        INT         NOT NULL,
    CONSTRAINT FK_ALUNO_TURMA FOREIGN KEY (Cod_Turma) REFERENCES TURMA(Cod_Turma),
    CONSTRAINT FK_ALUNO_CURSO FOREIGN KEY (Cod_Curso) REFERENCES CURSO(Cod_Curso)
);

-- ============================================================
-- NOTA SOBRE O ENDEREÇO:
--   O modelo lógico normaliza o endereço em tabelas separadas
--   (Endereco_Aluno, Bairro_Aluno, Cidade_Aluno, Estado_Aluno).
--   O campo VARCHAR(100) aqui é uma simplificação deliberada
--   do modelo físico para o escopo do projeto.
--   Para implementação completa, ver modelo lógico (.png).
-- ============================================================

CREATE TABLE HISTORICO (
    Cod_Historico      INT        PRIMARY KEY,
    RA                 VARCHAR(8) NOT NULL,
    -- Periodo_Realizacao representa o semestre (ex.: 20251 = 1º sem. 2025)
    Periodo_Realizacao INT        NOT NULL,
    Data_Inicio        DATE       NOT NULL,
    Data_Fim           DATE       NOT NULL,
    CONSTRAINT FK_HIST_ALUNO FOREIGN KEY (RA) REFERENCES ALUNO(RA),
    CONSTRAINT CHK_HIST_DATAS CHECK (Data_Fim > Data_Inicio)
);

-- ============================================================
-- 3. TABELAS ASSOCIATIVAS (N:N)
-- ============================================================

CREATE TABLE PROF_DISCIPLINA (
    Cod_Professor  INT NOT NULL,
    Cod_Disciplina INT NOT NULL,
    PRIMARY KEY (Cod_Professor, Cod_Disciplina),
    CONSTRAINT FK_PD_PROF FOREIGN KEY (Cod_Professor)  REFERENCES PROFESSOR(Cod_Professor),
    CONSTRAINT FK_PD_DISC FOREIGN KEY (Cod_Disciplina) REFERENCES DISCIPLINA(Cod_Disciplina)
);
-- RN: cada professor leciona no máximo 4 disciplinas.
-- Essa restrição exige TRIGGER ou validação na camada de aplicação (não pode ser expressa com CHECK simples).

CREATE TABLE CURSO_DISCIPLINA (
    Cod_Curso      INT NOT NULL,
    Cod_Disciplina INT NOT NULL,
    PRIMARY KEY (Cod_Curso, Cod_Disciplina),
    CONSTRAINT FK_CD_CURSO FOREIGN KEY (Cod_Curso)      REFERENCES CURSO(Cod_Curso),
    CONSTRAINT FK_CD_DISC  FOREIGN KEY (Cod_Disciplina) REFERENCES DISCIPLINA(Cod_Disciplina)
);

-- Matrícula do aluno em disciplina no semestre (N:N entre ALUNO e DISCIPLINA)
-- Corrigido: tabela estava presente no modelo lógico e no dicionário mas ausente no SQL original.
CREATE TABLE ALUNO_DISCIPLINA (
    RA             VARCHAR(8) NOT NULL,
    Cod_Disciplina INT        NOT NULL,
    PRIMARY KEY (RA, Cod_Disciplina),
    CONSTRAINT FK_AD_ALUNO FOREIGN KEY (RA)             REFERENCES ALUNO(RA),
    CONSTRAINT FK_AD_DISC  FOREIGN KEY (Cod_Disciplina) REFERENCES DISCIPLINA(Cod_Disciplina)
);
-- RN: cada aluno pode se matricular em no máximo 9 disciplinas por semestre.
-- Requer TRIGGER ou validação na camada de aplicação.

CREATE TABLE DISC_HIST (
    Cod_Historico  INT            NOT NULL,
    Cod_Disciplina INT            NOT NULL,
    Nota           DECIMAL(4,2)   NOT NULL CHECK (Nota >= 0 AND Nota <= 10),
    -- Frequencia em percentual (0-100)
    Frequencia     DECIMAL(5,2)   NOT NULL CHECK (Frequencia >= 0 AND Frequencia <= 100),
    PRIMARY KEY (Cod_Historico, Cod_Disciplina),
    CONSTRAINT FK_DH_HIST FOREIGN KEY (Cod_Historico)  REFERENCES HISTORICO(Cod_Historico),
    CONSTRAINT FK_DH_DISC FOREIGN KEY (Cod_Disciplina) REFERENCES DISCIPLINA(Cod_Disciplina)
);
-- RN: aluno só pode ser reprovado no máximo 3 vezes na mesma disciplina.
-- Requer TRIGGER ou consulta de validação (contar ocorrências de reprovação por RA+Disciplina).

-- ============================================================
-- 4. TRIGGER DE EXEMPLO — Limite de disciplinas por professor
--    (Demonstra a implementação de RN não expressável com CHECK)
-- ============================================================
DELIMITER $$
CREATE TRIGGER trg_limite_disc_professor
BEFORE INSERT ON PROF_DISCIPLINA
FOR EACH ROW
BEGIN
    DECLARE qtd INT;
    SELECT COUNT(*) INTO qtd
    FROM PROF_DISCIPLINA
    WHERE Cod_Professor = NEW.Cod_Professor;

    IF qtd >= 4 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Professor não pode lecionar mais de 4 disciplinas.';
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- 5. INSERÇÃO DE DADOS DE TESTE (DML)
-- ============================================================

INSERT INTO DEPARTAMENTO VALUES
    (1, 'Tecnologia da Informação'),
    (2, 'Matemática');

INSERT INTO CURSO VALUES
    (1, 'Ciência da Computação', 1),
    (2, 'Sistemas de Informação', 1);

INSERT INTO DISCIPLINA VALUES
    (1, 'Banco de Dados I',   'Modelagem e SQL',          80, 30, 1),
    (2, 'Algoritmos',         'Lógica de programação',    60, 30, 1),
    (3, 'Banco de Dados II',  'Consultas avançadas',      80, 30, 1);

-- Pré-requisito: BD II depende de BD I
INSERT INTO DISC_PREREQ VALUES (3, 1);

INSERT INTO PROFESSOR VALUES
    (1, 'Fábio',  'Boson',   TRUE, 1),
    (2, 'Ana',    'Souza',   TRUE, 2);

INSERT INTO TURMA VALUES
    (101, 'Noturno',  30, '2025-02-01', '2025-07-01', 1),
    (102, 'Matutino', 30, '2025-02-01', '2025-07-01', 2);

INSERT INTO ALUNO VALUES
    ('20260001', 'Danielli', 'Arçari',  '000.000.000-00', 'M', 'F', 'Filiação A', 'Rua 1, 100, Itabira-MG', 101, 1),
    ('20260002', 'Álvaro',   'Arçari',  '111.111.111-11', 'M', 'M', 'Filiação B', 'Rua 1, 100, Itabira-MG', 101, 1),
    ('20260003', 'Leonardo', 'Arçari',  '222.222.222-22', 'M', 'M', 'Filiação C', 'Rua 2, 200, Itabira-MG', 102, 2);

INSERT INTO HISTORICO VALUES
    (1, '20260001', 20251, '2025-02-01', '2025-07-01'),
    (2, '20260002', 20251, '2025-02-01', '2025-07-01');

INSERT INTO PROF_DISCIPLINA VALUES (1, 1), (1, 2), (2, 3);
INSERT INTO CURSO_DISCIPLINA  VALUES (1, 1), (1, 2), (2, 3);
INSERT INTO ALUNO_DISCIPLINA  VALUES ('20260001', 1), ('20260001', 2), ('20260002', 1);

INSERT INTO DISC_HIST VALUES
    (1, 1, 8.50,  85.00),
    (1, 2, 7.00,  90.00),
    (2, 1, 5.50,  60.00);

-- ============================================================
-- 6. CONSULTAS DE VALIDAÇÃO / ANALYTICS
-- ============================================================

-- 6.1 Todos os alunos cadastrados
SELECT * FROM ALUNO;

-- 6.2 Alunos, seus cursos e notas (JOIN completo)
SELECT
    A.RA,
    CONCAT(A.Nome_Aluno, ' ', A.Sobrenome_Aluno) AS Aluno,
    C.Nome_Curso,
    D.Nome_Disciplina,
    DH.Nota,
    DH.Frequencia
FROM ALUNO A
JOIN CURSO           C  ON A.Cod_Curso        = C.Cod_Curso
JOIN HISTORICO       H  ON A.RA               = H.RA
JOIN DISC_HIST       DH ON H.Cod_Historico    = DH.Cod_Historico
JOIN DISCIPLINA      D  ON DH.Cod_Disciplina  = D.Cod_Disciplina
ORDER BY A.RA, D.Nome_Disciplina;

-- 6.3 Professores e as disciplinas que lecionam
-- (Corrigido: versão original do README fazia JOIN incorreto por departamento)
SELECT
    CONCAT(P.Nome_Professor, ' ', P.Sobrenome_Professor) AS Professor,
    D.Nome_Disciplina
FROM PROFESSOR P
JOIN PROF_DISCIPLINA PD ON P.Cod_Professor  = PD.Cod_Professor
JOIN DISCIPLINA      D  ON PD.Cod_Disciplina = D.Cod_Disciplina
ORDER BY Professor;

-- 6.4 Alunos e seus respectivos professores (via disciplinas cursadas)
SELECT DISTINCT
    CONCAT(A.Nome_Aluno,  ' ', A.Sobrenome_Aluno)  AS Aluno,
    C.Nome_Curso,
    CONCAT(P.Nome_Professor, ' ', P.Sobrenome_Professor) AS Professor
FROM ALUNO           A
JOIN CURSO           C  ON A.Cod_Curso        = C.Cod_Curso
JOIN ALUNO_DISCIPLINA AD ON A.RA              = AD.RA
JOIN PROF_DISCIPLINA  PD ON AD.Cod_Disciplina = PD.Cod_Disciplina
JOIN PROFESSOR        P  ON PD.Cod_Professor  = P.Cod_Professor
ORDER BY Aluno, Professor;

-- 6.5 Média de notas por aluno
SELECT
    A.RA,
    CONCAT(A.Nome_Aluno, ' ', A.Sobrenome_Aluno) AS Aluno,
    ROUND(AVG(DH.Nota), 2)       AS Media_Geral,
    ROUND(AVG(DH.Frequencia), 2) AS Frequencia_Media
FROM ALUNO A
JOIN HISTORICO  H  ON A.RA            = H.RA
JOIN DISC_HIST  DH ON H.Cod_Historico = DH.Cod_Historico
GROUP BY A.RA, Aluno
ORDER BY Media_Geral DESC;