
       PROGRAM-ID. samplezap.
       CONFIGURATION SECTION.
       special-names.
       decimal-point is comma.
       
       repository.
        class web-area as "com.iscobol.rts.HTTPHandler"
        class Crypt as "com.interon.cryptography.Decipher"
        class Blockexception as 
             "javax.crypto.IllegalBlockSizeException"
       .
           
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           
        select product assign to  "tblProduct"
               organization is indexed
               access mode is dynamic
               record key is productPK = productCode
               lock mode is automatic
               file status is fsTblProduct
       .

       DATA DIVISION.
       FILE SECTION.
       fd product.
       01 tblProductRec.
          03 productCode pic x(15).
          03 productName pic x(150).
          03 productCategory pic x(100).
          03 productQuantity pic ZZZZZ.
          03 productPrice pic ZZZ.ZZZ,ZZ.
          03 productURL pic x(300).
          03 productDescription pic x(300).

       WORKING-STORAGE SECTION.
       77 fsTblProduct pic x(2).
          88 valid-Product         value is "00" thru "09".
       77  bf                  object reference Crypt.
       77  dkey                pic x any length
           value "NV2M5TnBxtHznZiBF85yNEP1FbnPPqvD".
       77  ekey                pic x any length
           value "lgmsTAiDqINHDQgu58gM2d3AKpPwV/tM".
       77  crypt-text          pic x any length.
       77  crypt-iv            pic x any length.
       77  json-text           pic x any length.
       77  finalresponse       pic x any length.
       77  newIV               pic x any length.
       77  ws-status           pic x(2).
		  
       *> variavel para atribuir o codigo digitado pelo usuario  
         01  getcode identified by "".
             03 identified by "produtoCodigo".
                05 prdcode      pic x any length.
                
       *> variavel para atribuir o IV (Initial Vector)
         01  annaexec identified by "".
             03 identified by "ANNAEXEC".
                05 receivedIV   pic x any length. 

       LINKAGE SECTION.
        01  comm-area object reference web-area.
       
       PROCEDURE DIVISION USING comm-area.
       INICIO.
           
       *> recebe as variaveis vindas do whatsapp 
       comm-area:>accept(annaexec).
       comm-area:>accept (getcode).
       
       *> cria uma instancia da classe Decipher
       set bf to Crypt:>new()
        
       *> necessario utilizar TRY / CATCH pois podem ocorrer excecoes    
       try
       *> o valor do codigo recebido deve ser decriptado
       *> sendo passado como parametro para o metodo "isDecrypt" 
       *> junto com a chave de decriptar e o IV recebido
       *> em seguida o valor sera atribuido para a variavel "prdcode"
          set prdcode 
              to bf:>"iscDecrypt"(prdcode, dkey, receivedIV) 
              
        catch Blockexception
              comm-area:>displayText("erro BlockException")
       end-try. 
			      
       set environment "file.index" to "jisam"
       open input product
       move $upper-case(prdcode) to productCode with convert
       start product key = productPK 
       read product with no lock
            
       if not valid-product
           initialize tblProductRec
           move 'no' to ws-status 
         else
           move 'ok' to ws-status
       end-if
       
       *> monta o json de resposta para o whatsapp  
       string 
       '['
        '{'
        '"PropName": "Container001",'
        '"PropValue":'
           '['
       
             '{'
              '"PropName": "Alias",'
              '"PropValue": "parmsProduct"'
             '},'
       
             '{'
              '"PropName": "Type",'
              '"PropValue": "EXECFUNCTION"'
             '},'
       
            '{'
             '"PropName": "EXPRESSION",'
             '"PropValue":'
                   '"AddParm(prodNam,' productName ')'
                    'AddParm(prodCat,' productCategory ')'
                    'AddParm(prodQtd,' productQuantity ')'
                    'AddParm(prodPri,' productPrice')'
                    'AddParm(prodDes,' productDescription ')'
                    'AddParm(prodURLimg,' productURL ')'
                    'AddParm(status, ' ws-status ')"'
           '}'
           
          ']'
        '}'
       ']'
                  
       delimited by size into json-text
       close product.
       
       *> necessario utilizar TRY / CATCH pois podem ocorrer excecoes
       try 
          *> gera um novo IV utilizando o metodo "createsIV" 
          *> atribui o novo IV para a variavel "newIV"
          set newIV to bf:>"createsIV"()
          
          *> criptografa o json de resposta o passando como parametro 
          *> para o metodo "iscEncrypt" mais a chave de encriptar e o novo IV
          *> atribui o resultado para a variavel "crypt-text"
          set crypt-text to bf:>"iscEncrypt"(json-text, ekey, newIV)

          *> criptografa o novo IV o passando como parametro para o metodo "iscEncrypt"
          *>  mais a chave de decriptar e o IV recebido
          set crypt-iv to bf:>"iscEncrypt"(newIV, dkey, receivedIV)
                   
         catch Blockexception
              comm-area:>displayText("erro BlockException") 
       end-try. 
           
       *> concatena o json de resposta + o IV recebido + o novo IV
       *> atribui o resultado para a variavel "finalResponse"
       *> e retorna essa resposta para o whatsapp
        initialize finalresponse 
           string crypt-text
                  receivedIV
                  crypt-iv 
        delimited by size into finalresponse

        comm-area:>displayText(finalresponse)
        goback.
