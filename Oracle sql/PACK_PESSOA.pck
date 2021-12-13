CREATE OR REPLACE PACKAGE PACK_PESSOA IS

-- AUTHOR  : DOUGLAS OLIVEIRA
-- CREATED : 19/11/2021 07:54:07
-- PURPOSE : PACOTE PARA CENTRALIZAR OS PROCEDIMENTOS REFENTE A PESSOA
  
   PROCEDURE INSERE_PESSOA (I_NR_CPF        IN PESSOA.NR_CPF%TYPE,
                           I_NM_PESSOA      IN PESSOA.NM_PESSOA%TYPE,
                           I_DT_NASCIMENTO  IN PESSOA.DT_NASCIMENTO%TYPE,
                           O_MENSAGEM      OUT VARCHAR2);
                           
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
   PROCEDURE INSERE_SALA (I_CD_SALA     IN OUT SALA.CD_SALA%TYPE,
                          I_DS_SALA     IN SALA.DS_SALA%TYPE,
                          I_VL_HORASALA IN SALA.VL_HORASALA%TYPE,
                          I_DS_PREDIO   IN SALA.DS_PREDIO%TYPE,
                          O_MENSAGEM    OUT VARCHAR2);
         
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
PROCEDURE INSERE_RESERVA   (I_CD_RESERVA   IN OUT RESERVA.CD_RESERVA%TYPE,
                            I_CD_SALA      IN RESERVA.CD_SALA%TYPE,
                            I_VL_HORA      IN OUT RESERVA.VL_HORA%TYPE,
                            I_QT_HORAS     IN RESERVA.QT_HORAS%TYPE,
                            I_NR_CPFPESSOA IN RESERVA.NR_CPFPESSOA%TYPE,
                            I_DT_RESERVADA IN RESERVA.DT_RESERVADA%TYPE,
                            O_MENSAGEM     OUT VARCHAR2);
                            
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
PROCEDURE EXCLUI_PESSOA (I_NR_CPF   IN PESSOA.NR_CPF%TYPE,
                          O_MENSAGEM   OUT VARCHAR2);
                          
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------                                                    
PROCEDURE EXCLUI_SALA (I_CD_SALA   IN SALA.CD_SALA%TYPE,
                          O_MENSAGEM   OUT VARCHAR2);
                          
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------                          
PROCEDURE EXCLUI_RESERVA (I_CD_RESERVA   IN RESERVA.CD_RESERVA%TYPE,
                          O_MENSAGEM   OUT VARCHAR2);                          
                   
END PACK_PESSOA;
/
CREATE OR REPLACE PACKAGE BODY PACK_PESSOA IS

  PROCEDURE INSERE_PESSOA (I_NR_CPF        IN PESSOA.NR_CPF%TYPE,
                           I_NM_PESSOA     IN PESSOA.NM_PESSOA%TYPE,
                           I_DT_NASCIMENTO IN PESSOA.DT_NASCIMENTO%TYPE,
                           O_MENSAGEM      OUT VARCHAR2) IS
    
    V_NR_CPF PESSOA.NR_CPF%TYPE; 
    E_GERAL EXCEPTION;
  BEGIN
    IF I_NR_CPF IS NULL THEN
      O_MENSAGEM := 'O CPF precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF I_NM_PESSOA IS NULL THEN
      O_MENSAGEM := 'O nome precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF I_DT_NASCIMENTO IS NULL THEN
      O_MENSAGEM := 'A data de nascimento precisa ser informada!';
      RAISE E_GERAL;
    END IF;
    
    IF LENGTH(I_NR_CPF) <> 11 THEN
      O_MENSAGEM := 'CPF informado é inválido!';
      RAISE E_GERAL;
    END IF;
    
    IF INSTR(I_NM_PESSOA,' ') = 0 THEN
      O_MENSAGEM := 'Precisa ser informado o nome completo!';
      RAISE E_GERAL;
    END IF;  
                                
  BEGIN
    SELECT MAX(PESSOA.NR_CPF)
      INTO V_NR_CPF
      FROM PESSOA;
    
    BEGIN   
      INSERT INTO PESSOA
        (NR_CPF,
         NM_PESSOA,
         DT_NASCIMENTO)
      VALUES
         (I_NR_CPF,
          I_NM_PESSOA,
          I_DT_NASCIMENTO);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE PESSOA
             SET NR_CPF = I_NR_CPF,
                 NM_PESSOA = I_NM_PESSOA,
                 DT_NASCIMENTO = I_DT_NASCIMENTO
           WHERE NR_CPF = I_NR_CPF;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar pessoa. Erro: '||SQLERRM;
            RAISE E_GERAL;
        END;
    END;
        
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir pessoa. Erro: '||SQLERRM;
        RAISE E_GERAL;
  END;
  
  COMMIT;
        
 EXCEPTION
      WHEN E_GERAL THEN
        O_MENSAGEM := '[INSERE_PESSOA] '||O_MENSAGEM;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro no procedimento que insere uma pessoa: '||SQLERRM;
  END;
  
  --------------------------------------------------------------------
  --------------------------------------------------------------------
  ------INSERIR SALA--------------------------------------------------
  PROCEDURE INSERE_SALA (I_CD_SALA     IN OUT SALA.CD_SALA%TYPE,
                         I_DS_SALA     IN SALA.DS_SALA%TYPE,
                         I_VL_HORASALA IN SALA.VL_HORASALA%TYPE,
                         I_DS_PREDIO   IN SALA.DS_PREDIO%TYPE,
                         O_MENSAGEM    OUT VARCHAR2) IS
    
    V_CD_SALA SALA.CD_SALA%TYPE;
    E_GERAL EXCEPTION;
    
  BEGIN
    
    IF I_DS_SALA IS NULL THEN
      O_MENSAGEM := 'A descrição da sala precisa ser informado!';
      RAISE E_GERAL;
    END IF; 
    
    IF I_VL_HORASALA IS NULL THEN
      O_MENSAGEM := 'O valor por hora precisa ser informado!';
      RAISE E_GERAL;
    END IF; 
    
     IF I_DS_PREDIO IS NULL THEN
      O_MENSAGEM := 'A descrição do predio precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF I_CD_SALA IS NULL THEN
      BEGIN
        SELECT MAX(SALA.CD_SALA)
          INTO I_CD_SALA
          FROM SALA;
      EXCEPTION
        WHEN OTHERS THEN
          I_CD_SALA := 0;
      END;
      END IF;
      I_CD_SALA := NVL(I_CD_SALA,0) + 1;
                              
  BEGIN
    INSERT INTO SALA
      (CD_SALA,
       DS_SALA,
       VL_HORASALA,
       DS_PREDIO)
     VALUES
       (I_CD_SALA,
        I_DS_SALA,
        I_VL_HORASALA,
        I_DS_PREDIO); 
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      BEGIN
        UPDATE SALA
           SET CD_SALA = I_CD_SALA,
               DS_SALA = I_DS_SALA,
               VL_HORASALA = I_VL_HORASALA,
               DS_PREDIO = I_DS_PREDIO
         WHERE CD_SALA = I_CD_SALA;
      EXCEPTION
        WHEN OTHERS THEN
          O_MENSAGEM := 'Erro ao atualizar sala. Erro: '||SQLERRM;
          RAISE E_GERAL;
      END;
      WHEN OTHERS THEN
         O_MENSAGEM := 'Erro ao inserir sala. Erro: '||SQLERRM;
         RAISE E_GERAL;   
      END;
      
      COMMIT;
  
  EXCEPTION 
    WHEN E_GERAL THEN
      O_MENSAGEM := '[INSERE SALA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro ao inserir nota fiscal. Erro: '||SQLERRM;
  END;
  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  ------INSERIR RESERVA--------------------------------------------------                
  PROCEDURE INSERE_RESERVA (I_CD_RESERVA   IN OUT RESERVA.CD_RESERVA%TYPE,
                            I_CD_SALA      IN RESERVA.CD_SALA%TYPE,
                            I_VL_HORA      IN OUT RESERVA.VL_HORA%TYPE,
                            I_QT_HORAS     IN RESERVA.QT_HORAS%TYPE,
                            I_NR_CPFPESSOA IN RESERVA.NR_CPFPESSOA%TYPE,
                            I_DT_RESERVADA IN RESERVA.DT_RESERVADA%TYPE,
                            O_MENSAGEM     OUT VARCHAR2) IS 
    V_COUNT RESERVA.CD_SALA%TYPE;                                            
    E_GERAL EXCEPTION; 
  BEGIN  
  
    IF I_CD_SALA IS NULL THEN
      O_MENSAGEM := 'O codigo da sala precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
   
    
    IF I_QT_HORAS IS NULL THEN
      O_MENSAGEM := 'A quantidade de hora precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF I_NR_CPFPESSOA IS NULL THEN
      O_MENSAGEM := 'O CPF precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF I_DT_RESERVADA IS NULL THEN
      O_MENSAGEM := 'A data precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF LENGTH(I_NR_CPFPESSOA) <> 11 THEN
      O_MENSAGEM := 'CPF informado é inválido!';
      RAISE E_GERAL;
    END IF;
    
      BEGIN
        SELECT MAX(SALA.VL_HORASALA)
          INTO I_VL_HORA 
          FROM SALA;
     
       I_VL_HORA := I_VL_HORA * I_QT_HORAS  ;
    END;
    
     BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM SALA
       WHERE SALA.CD_SALA = I_CD_SALA;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
     END;
     IF NVL(V_COUNT,0) = 0 THEN
       O_MENSAGEM := 'Verifique o código da sala. Não cadastrado ['||I_CD_SALA||'].';
       RAISE E_GERAL; 
     END IF;
    
     BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PESSOA
       WHERE PESSOA.NR_CPF = I_NR_CPFPESSOA;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END; 
    
    IF NVL(V_COUNT,0) = 0 OR V_COUNT = I_NR_CPFPESSOA   THEN
      O_MENSAGEM := 'Verifique o código da sala. Não cadastrado ['||I_NR_CPFPESSOA||'].';
      RAISE E_GERAL; 
    END IF;
    
    IF I_CD_RESERVA IS NULL THEN
      BEGIN
        SELECT MAX(RESERVA.CD_RESERVA)
          INTO I_CD_RESERVA
          FROM RESERVA;
      EXCEPTION
        WHEN OTHERS THEN
          I_CD_RESERVA := 0;
          END;
          END IF;
       I_CD_RESERVA := NVL(I_CD_RESERVA,0) + 1;
             
      BEGIN
        INSERT INTO RESERVA(
          CD_RESERVA,
          CD_SALA,
          VL_HORA,
          QT_HORAS,
          NR_CPFPESSOA,
          DT_RESERVADA)
        VALUES(
          I_CD_RESERVA,
          I_CD_SALA,
          I_VL_HORA,
          I_QT_HORAS,
          I_NR_CPFPESSOA,
          I_DT_RESERVADA);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          BEGIN
            UPDATE RESERVA         
               SET CD_SALA      = I_CD_SALA,
                   VL_HORA      = I_VL_HORA,
                   QT_HORAS     = I_QT_HORAS,
                   NR_CPFPESSOA = I_NR_CPFPESSOA
             WHERE CD_RESERVA   = I_CD_RESERVA;
           EXCEPTION
             WHEN OTHERS THEN
               O_MENSAGEM := 'Erro ao atualizar reserva. Erro: '|| SQLERRM;
               RAISE E_GERAL;
          END;
         WHEN OTHERS THEN
           O_MENSAGEM := 'Erro ao inserir pessoa. Erro: '||SQLERRM;
           RAISE E_GERAL;
       END;
       
       COMMIT;
       EXCEPTION
         WHEN E_GERAL THEN        
           O_MENSAGEM := '[INSERE_RESERVA] '||O_MENSAGEM;
         WHEN OTHERS THEN          
           O_MENSAGEM := 'Erro no procedimento que insere uma reserva: '||SQLERRM;
     END;
  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  ------EXCLUIR PESSOA--------------------------------------------------     
   PROCEDURE EXCLUI_PESSOA (I_NR_CPF   IN PESSOA.NR_CPF%TYPE,
                          O_MENSAGEM   OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN
    IF I_NR_CPF IS NULL THEN
      O_MENSAGEM := 'Informe o cpf';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE PESSOA
       WHERE NR_CPF = I_NR_CPF;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir pessoa: '||SQLERRM;
        RAISE E_GERAL;
    END;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_PESSOA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := 'Erro no procedimento de exclusão de pessoa: '||SQLERRM;
  END;  
  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  ------EXCLUIR SALA-----------------------------------------------------   
  PROCEDURE EXCLUI_SALA (I_CD_SALA   IN SALA.CD_SALA%TYPE,
                          O_MENSAGEM   OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN
    IF I_CD_SALA IS NULL THEN
      O_MENSAGEM := 'Informe o codigo da sala';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE SALA
       WHERE CD_SALA = I_CD_SALA;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir sala: '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[EXCLUI_SALA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro no procedimento de exclusão de sala: '||SQLERRM;
  END;
  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  ------EXCLUIR RESERVA-----------------------------------------------------   
  PROCEDURE EXCLUI_RESERVA (I_CD_RESERVA   IN RESERVA.CD_RESERVA%TYPE,
                          O_MENSAGEM   OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN
    IF I_CD_RESERVA IS NULL THEN
      O_MENSAGEM := 'Informe o codigo da reserva';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE RESERVA
       WHERE CD_RESERVA = I_CD_RESERVA;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir reserva: '||SQLERRM;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[EXCLUI_RESERVA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro no procedimento de exclusão de reserva: '||SQLERRM;
  END; 
          
                   
       
END PACK_PESSOA;
 -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  ------SOMA RESERVA-----------------------------------------------------
/
