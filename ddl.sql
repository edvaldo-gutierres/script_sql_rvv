--Criando o banco de dados

CREATE DATABASE rvv
GO	

-- Criando tabelas
USE rvv;

------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Comissao;
DROP TABLE IF EXISTS dbo.Resultado;
DROP TABLE IF EXISTS dbo.Meta;
DROP TABLE IF EXISTS dbo.Colaborador;
DROP TABLE IF EXISTS dbo.Indicadores;

------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Departamento;
CREATE TABLE dbo.Departamento
(
    Codigo_do_Departamento INT NOT NULL IDENTITY(1000, 1),
    Nome_do_Departamento VARCHAR(30) NOT NULL,
    Status_do_Departamento BIT NOT NULL,
    CONSTRAINT PK_Departamento
        PRIMARY KEY (Codigo_do_Departamento)
);

------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Cargo;
CREATE TABLE dbo.Cargo
(
    Codigo_do_Cargo INT NOT NULL IDENTITY(1000, 1),
    Nome_do_Cargo VARCHAR(30) NOT NULL,
    Status_do_Cargo BIT NOT NULL,
    nivel_hierarquia INT NOT NULL,
	Base_de_Calculo VARCHAR(25) NOT NULL CONSTRAINT Base_de_Calculo CHECK (Base_de_Calculo IN ('Salario', 'Faturamento','Nao Elegivel')),
    CONSTRAINT PK_Cargo
        PRIMARY KEY (Codigo_do_Cargo)
);

------------------------------------------------------------------------------

CREATE TABLE dbo.Colaborador
(
    Matricula_do_Colaborador INT IDENTITY(1000001, 1),
    Nome_do_Colaborador VARCHAR(150) NOT NULL,
    Sexo VARCHAR(1) NOT NULL
        CONSTRAINT Sexo CHECK (Sexo IN ( 'F', 'M' )),
    CPF VARCHAR(14)
        UNIQUE,
    Data_Nascimento DATE NOT NULL,
    Codigo_do_Departamento INT NOT NULL,
    Codigo_do_Cargo INT NOT NULL,
    Salario DECIMAL(32, 2) NOT NULL,
    Status_do_Colaborador BIT NOT NULL,
    CONSTRAINT PK_Colaborador
        PRIMARY KEY (Matricula_do_Colaborador)
);

ALTER TABLE dbo.Colaborador
ADD CONSTRAINT FK_Colaborador_Cargo
    FOREIGN KEY (Codigo_do_Cargo)
    REFERENCES dbo.Cargo (Codigo_do_Cargo);

ALTER TABLE dbo.Colaborador
ADD CONSTRAINT FK_Colaborador_Departamento
    FOREIGN KEY (Codigo_do_Departamento)
    REFERENCES dbo.Departamento (Codigo_do_Departamento);

------------------------------------------------------------------------------


CREATE TABLE dbo.Indicadores
(
    Codigo_do_Indicador INT NOT NULL IDENTITY(1, 1),
    Nome_do_Indicador VARCHAR(50) NOT NULL,
    Codigo_do_Departamento INT NOT NULL,
    Codigo_do_Cargo INT NOT NULL,
    Peso_do_Indicador DECIMAL(32, 8) NOT NULL,
    Inicio_Vigencia DATE NOT NULL,
    Final_Vigencia DATE NULL,
    CONSTRAINT PK_Indicadores
        PRIMARY KEY (Codigo_do_Indicador)
);

ALTER TABLE dbo.Indicadores
ADD CONSTRAINT FK_Indicicador_Cargo
    FOREIGN KEY (Codigo_do_Cargo)
    REFERENCES dbo.Cargo (Codigo_do_Cargo);


ALTER TABLE dbo.Indicadores
ADD CONSTRAINT FK_Indicador_Departamento
    FOREIGN KEY (Codigo_do_Departamento)
    REFERENCES dbo.Departamento (Codigo_do_Departamento);


---------------------------------------------------------------------------


CREATE TABLE dbo.Meta
(
    id_meta INT NOT NULL IDENTITY(1, 1),
    Matricula_do_Colaborador INT NOT NULL,
    Codigo_do_Indicador INT NOT NULL,
    Inicio_Vigencia DATE NOT NULL,
    Final_Vigencia DATE NULL,
    Valor_da_Meta DECIMAL(32, 8) NOT NULL,
    CONSTRAINT PK_Meta
        PRIMARY KEY (id_meta)
);

ALTER TABLE dbo.Meta
ADD CONSTRAINT FK_Meta_Colaborador
    FOREIGN KEY (Matricula_do_Colaborador)
    REFERENCES dbo.Colaborador (Matricula_do_Colaborador);

ALTER TABLE dbo.Meta
ADD CONSTRAINT FK_Meta_Indicador
    FOREIGN KEY (Codigo_do_Indicador)
    REFERENCES dbo.Indicadores (Codigo_do_Indicador);


---------------------------------------------------------------------------

CREATE TABLE dbo.Resultado
(
    id_resultado INT NOT NULL IDENTITY(1, 1),
    Matricula_do_Colaborador INT NOT NULL,
    Codigo_do_Indicador INT NOT NULL,
    Competencia DATE NOT NULL,
    Valor_do_Resultado DECIMAL(32, 8) NOT NULL,
    CONSTRAINT PK_Resultado
        PRIMARY KEY (id_resultado)
);

ALTER TABLE dbo.Resultado
ADD CONSTRAINT FK_Resultado_Colaborador
    FOREIGN KEY (Matricula_do_Colaborador)
    REFERENCES dbo.Colaborador (Matricula_do_Colaborador);

ALTER TABLE dbo.Resultado
ADD CONSTRAINT FK_Resultado_Indicador
    FOREIGN KEY (Codigo_do_Indicador)
    REFERENCES dbo.Indicadores (Codigo_do_Indicador);


---------------------------------------------------------------------------


CREATE TABLE dbo.Comissao
(
    id_comissao INT NOT NULL IDENTITY(1, 1),
	id_meta INT NOT NULL,
	id_resultado INT NOT NULL,
    Matricula_do_Colaborador INT NOT NULL,
    Codigo_do_Indicador INT NOT NULL,
    Competencia DATE NOT NULL,
    Valor_do_Resultado DECIMAL(32, 8) NOT NULL,
    Valor_da_Meta DECIMAL(32, 8) NOT NULL,
    Atingimento DECIMAL(32, 8) NOT NULL,
    Peso_do_Indicador DECIMAL(32, 8) NOT NULL,
    Base_Calculo DECIMAL(32, 8) NOT NULL,
    Comissao DECIMAL(32, 8) NOT NULL,
    CONSTRAINT PK_Comissao
        PRIMARY KEY (id_comissao)
);

ALTER TABLE dbo.Comissao
ADD CONSTRAINT FK_Comissao_Colaborador
    FOREIGN KEY (Matricula_do_Colaborador)
    REFERENCES dbo.Colaborador (Matricula_do_Colaborador);

ALTER TABLE dbo.Comissao
ADD CONSTRAINT FK_Comissao_Indicador
    FOREIGN KEY (Codigo_do_Indicador)
    REFERENCES dbo.Indicadores (Codigo_do_Indicador);

ALTER TABLE dbo.Comissao
ADD CONSTRAINT FK_Comissao_Meta
	FOREIGN KEY (id_meta)
	REFERENCES dbo.Meta (id_meta);

ALTER TABLE dbo.Comissao
ADD CONSTRAINT FK_Comissao_Resultado
	FOREIGN KEY (id_resultado)
	REFERENCES dbo.Resultado (id_resultado);

