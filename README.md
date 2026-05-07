#  Gerenciamento de Dados Acadêmicos - Projeto de Banco de Dados Relacional

> Este projeto contempla uma modelagem completa de um banco de dados para gerenciamento de faculdade: do levantamento de requisitos à implementação física em MySQL, passando por modelo conceitual, lógico, dicionário de dados e consultas analíticas.

---

## Sobre o Projeto

Este projeto percorre todas as etapas do ciclo de vida de um banco de dados relacional aplicado ao domínio acadêmico. O objetivo é centralizar o controle de **Alunos, Professores, Cursos, Disciplinas, Turmas e Histórico Escolar**, garantindo integridade referencial e suporte a consultas analíticas de desempenho.

O projeto foi desenvolvido como parte da formação em Ciência da Computação (UNINTER), com base na metodologia do curso de Modelagem de Dados de [Fábio Boson (Bóson Treinamentos)](https://www.youtube.com/watch?v=Q_KTYFgvu1s&list=PLucm8g_ezqNoNHU8tjVeHmRGBFnjDIlxD),  a quem são dados os devidos créditos.

---

## Estrutura do Repositório

```
 ProjetoBDFaculdade
 ┣ 📄 BD_ProjetoFaculdade.sql                  ← Script principal (DDL + DML + Queries)
 ┣ 📄 DicionarioDeDados_ProjetoBDFaculdade.xlsx ← Dicionário de dados completo
 ┣ 📄 RegrasDeNegocio_ProjetoBDFaculdade.docx   ← Levantamento de requisitos e regras de negócio
 ┣ 🖼️ Lógico_ProjetoBDFaculdade.png            ← Diagrama do Modelo Lógico
 ┣ 📄 Lógico_ProjetoBDFaculdade.brM3            ← Arquivo do Modelo Lógico (brModelo)
 ┗ 📄 ProjetoBDFaculdade.brM3                   ← Arquivo do Modelo Conceitual (brModelo)
```

---

## Etapas de Desenvolvimento

### 1. Levantamento de Requisitos e Regras de Negócio

As principais regras mapeadas foram:

- Um aluno só pode estar matriculado em um curso por vez
- Um aluno pode se matricular em no máximo **9 disciplinas por semestre**
- O aluno só pode ser reprovado no máximo **3 vezes** na mesma disciplina
- Cada disciplina comporta no máximo **30 alunos por turma**
- Cada professor leciona no máximo **4 disciplinas** e está vinculado a um departamento
- Professores podem ser cadastrados mesmo sem lecionar disciplinas
- Uma disciplina pode ter **pré-requisitos** (auto-relacionamento)
- O Histórico Escolar registra nota final, frequência e período de cada disciplina cursada

> Documento completo: `RegrasDeNegocio_ProjetoBDFaculdade.docx`

---

### 2. Modelagem Conceitual e Lógica

**Entidades identificadas:** `Aluno`, `Professor`, `Disciplina`, `Curso`, `Departamento`, `Turma`, `Histórico`

**Relacionamentos N:N** resolvidos com tabelas associativas:

| Tabela Associativa | Entidades envolvidas         |
|--------------------|------------------------------|
| `PROF_DISCIPLINA`  | Professor ↔ Disciplina       |
| `CURSO_DISCIPLINA` | Curso ↔ Disciplina           |
| `ALUNO_DISCIPLINA` | Aluno ↔ Disciplina (matrícula semestral) |
| `DISC_HIST`        | Histórico ↔ Disciplina (notas e frequência) |
| `DISC_PREREQ`      | Disciplina ↔ Disciplina (auto-relacionamento de pré-requisito) |

O modelo lógico foi normalizado até a **3ª Forma Normal (3FN)**, eliminando dependências parciais e transitivas.

> Diagrama do modelo lógico: `Lógico_ProjetoBDFaculdade.png`

---

### 3. Dicionário de Dados

Define o tipo, tamanho, restrições e descrição de cada atributo. Exemplos:

| Atributo        | Tipo         | Restrição     | Descrição                          |
|-----------------|--------------|---------------|------------------------------------|
| `RA`            | `VARCHAR(8)` | PK, NOT NULL  | Registro Acadêmico do aluno        |
| `CPF`           | `VARCHAR(14)`| NOT NULL, UNIQUE | Formato `000.000.000-00`        |
| `Nota`          | `DECIMAL(4,2)`| NOT NULL, CHECK (0–10) | Nota final da disciplina  |
| `Frequencia`    | `DECIMAL(5,2)`| NOT NULL, CHECK (0–100) | Frequência em percentual |
| `Status_Ativo`  | `BOOLEAN`    | NOT NULL, DEFAULT TRUE | Status do professor      |

> Dicionário completo: `DicionarioDeDados_ProjetoBDFaculdade.xlsx`

---

### 4. Implementação Física (MySQL 8.0)

O script `BD_ProjetoFaculdade.sql` realiza, nesta ordem:

1. **Criação do schema** (`ProjetoBDFaculdade`) com charset `utf8mb4`
2. **Criação das tabelas** respeitando a hierarquia de dependências (FKs)
3. **Constraints de integridade** - `CHECK`, `UNIQUE`, `NOT NULL`, `DEFAULT`
4. **Trigger de exemplo** - valida o limite de 4 disciplinas por professor no momento do INSERT
5. **Dados de teste** - população inicial do banco via DML
6. **Consultas analíticas** - JOINs para relatórios de desempenho

> **Regras de negócio que exigem TRIGGER ou validação na camada de aplicação** (não expressáveis com `CHECK` simples):
> - Limite de 9 disciplinas por aluno por semestre
> - Limite de 3 reprovações por aluno em uma mesma disciplina

---

## 🛠️ Ferramentas

| Ferramenta        | Uso                                      |
|-------------------|------------------------------------------|
| **brModelo**      | Modelagem conceitual e lógica            |
| **MySQL 8.0**     | SGBD                                     |
| **MySQL Workbench** | Interface de execução e visualização   |
| **SQL**           | DDL (estrutura), DML (dados), DQL (consultas) |

---

## ▶️ Como Executar

```bash
# 1. Certifique-se de ter o MySQL Server 8.0+ instalado
# 2. Clone este repositório
git clone https://github.com/seu-usuario/ProjetoBDFaculdade.git

# 3. Acesse o MySQL via terminal ou MySQL Workbench e execute:
mysql -u root -p < BD_ProjetoFaculdade.sql

# O banco ProjetoBDFaculdade será criado e populado automaticamente.
```

---

## 📊 Exemplos de Consultas (Analytics)

**Notas e frequência por aluno:**
```sql
SELECT
    A.RA,
    CONCAT(A.Nome_Aluno, ' ', A.Sobrenome_Aluno) AS Aluno,
    D.Nome_Disciplina,
    DH.Nota,
    DH.Frequencia
FROM ALUNO A
JOIN HISTORICO      H  ON A.RA               = H.RA
JOIN DISC_HIST      DH ON H.Cod_Historico    = DH.Cod_Historico
JOIN DISCIPLINA     D  ON DH.Cod_Disciplina  = D.Cod_Disciplina
ORDER BY A.RA, D.Nome_Disciplina;
```

**Professores e disciplinas que lecionam:**
```sql
SELECT
    CONCAT(P.Nome_Professor, ' ', P.Sobrenome_Professor) AS Professor,
    D.Nome_Disciplina
FROM PROFESSOR P
JOIN PROF_DISCIPLINA PD ON P.Cod_Professor   = PD.Cod_Professor
JOIN DISCIPLINA      D  ON PD.Cod_Disciplina = D.Cod_Disciplina
ORDER BY Professor;
```

**Média geral por aluno:**
```sql
SELECT
    CONCAT(A.Nome_Aluno, ' ', A.Sobrenome_Aluno) AS Aluno,
    ROUND(AVG(DH.Nota), 2)       AS Media_Geral,
    ROUND(AVG(DH.Frequencia), 2) AS Frequencia_Media
FROM ALUNO A
JOIN HISTORICO  H  ON A.RA            = H.RA
JOIN DISC_HIST  DH ON H.Cod_Historico = DH.Cod_Historico
GROUP BY A.RA, Aluno
ORDER BY Media_Geral DESC;
```

---

## 👩‍💻 Autora

**Danielli Arçari**
Estudante de Ciência da Computação — UNINTER
Foco em SQL, Python e Analytics Engineering

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/seu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/seu-usuario)
