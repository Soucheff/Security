# Criar o IntuneWin
1. Copiar os arquivos abaixo para a pasta input e utilizar o Install.ps1 como setup file: 
    * DeployFW.ps1 - Script responsável por importar as regras de firewall baseado em perfil
    * fwrule.jso - Arquivo com as regras iniciais que será atualizado por meio da rotina de remediation quando necessário
    * Install.ps1 - Script que irá realizar a configuração necessária para execução da rotina de importação das regras de firewall
    * Uninstall.ps1 - Script para realizar a limpeza dos arquivos; as regras de firewall aplicadas serão mantidas

# Criar o Win32 APP
1. Com o arquivo gerado(intunewin) deverá ser criado o App no intune para instalação
    * Acessar: https://intune.microsoft.com
    * Ir na aba de Apps -> Windows
    * Clicar em Add
    * Selecionar o tipo do Aplicativo como Windows App (Win32)
    * Importar o package gerado anteriormente (intunewin ou obter do repositório)
    * Preencher os dados da aplicação
    * Na aba de Program preencher nos campos:
        * Install Command: Powershell.exe -NoProfile -ExecutionPolicy ByPass -File .\Install.ps1
        * Uninstall Command: Powershell.exe -NoProfile -ExecutionPolicy ByPass -File .\Uninstall.ps1
        * Device restart behavior: No specific action
        * Demais opções podem ser mantidas no padrão
    * Na aba requisitos
        * Operating System Architecture: 32 e 64 bits
        * Minimum operating system: Windows 10 22H2
        * Demais itens podem ser mantidos em branco ou caso necessário ajustados
    * Na aba detection rules deverá ser preenchido
        * Rules format: Use a custom detection script
        * Script File: importar o arquivo: DetectionMethod.ps1
        * Demais itens podem ser mantidos no padrão
    * Na aba dependência não há necessidade de ajustes
    * Na aba Supersedence não há necessidade de ajustes
    * Na aba Assignments deverá ser selecionado o alvo das configurações
    * Criar o pacote

# Criar o fluxo automatizado de update do FWRule
1. Com o App criado deverá ser criado o fluxo para manter o FWRULE.JSON atualizado
    * Acessar: https://intune.microsoft.com
    * Em Devices -> Remediations e Create script package
    * Na aba Basics
        * Preencher com o padrão de nome adotado referenciando que será o processo de update das regras de firewall baseado em perfil
    * Na aba Settings
        * Em detection script file: utilizar o arquivo UpdateFWRuleDection.ps1
        * Em Remediation script file: utilizar o arquivo UpdateFWRuleRemediation.ps1
        * Demais configurações manter no padrão
    * Na aba Scope Tag não é obrigatório o preenchimento
    * Na aba Assignments
        * Deverá ser aplicado no mesmo grupo de máquinas alvo do aplicativo anteriormente criado, especificando o tempo desejado para avaliação

Concluido o processo de criação da rotina de deploy das regras de firewall baseado em perfil.
Lembrando que caso haja alteração no arquivo principal DeployFW.ps1 deverá ser cálculo o hash em SHA256 dele (Get-FileHash) e atualizado o arquivo (DetectionMethod.ps1) para que seja sempre mantido o arquivo íntegro
