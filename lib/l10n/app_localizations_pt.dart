// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Bloco de Notas Seguro';

  @override
  String get searchNotes => 'Pesquisar notas';

  @override
  String get searchLockedNotes => 'Pesquisar notas bloqueadas';

  @override
  String get batchMode => 'Modo em lote';

  @override
  String get lockedNotes => 'Notas bloqueadas';

  @override
  String get homeScreenWidget => 'Widget da tela inicial';

  @override
  String get ourNewApps => 'Nossos novos apps';

  @override
  String get inviteFriends => 'Convidar amigos para o app';

  @override
  String get sendFeedback => 'Enviar feedback';

  @override
  String get rateUs => 'Avaliar';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get languageChanged => 'Idioma atualizado';

  @override
  String get english => 'Inglês';

  @override
  String get hindi => 'Hindi';

  @override
  String get spanish => 'Espanhol';

  @override
  String get french => 'Francês';

  @override
  String get indonesian => 'Indonésio';

  @override
  String get brazilianPortuguese => 'Português (Brasil)';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get addNotesToHomeScreen => 'Adicione notas à tela inicial';

  @override
  String get widgetTipDescription =>
      'Fixe um widget para ver suas notas recentes sem abrir o app.';

  @override
  String get setUpWidget => 'Configurar widget';

  @override
  String get dismiss => 'Fechar';

  @override
  String get title => 'Título';

  @override
  String get content => 'Conteúdo';

  @override
  String get addNote => 'Adicionar nota';

  @override
  String get updateNote => 'Atualizar nota';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteNote => 'Excluir nota';

  @override
  String get deleteNoteConfirm =>
      'Tem certeza de que deseja excluir esta nota?';

  @override
  String get delete => 'Excluir';

  @override
  String get noteAdded => 'Nota adicionada';

  @override
  String get noteUpdated => 'Nota atualizada';

  @override
  String get noNotesYet => 'Nenhuma nota ainda.';

  @override
  String get noNotesMatchSearch => 'Nenhuma nota corresponde à sua pesquisa.';

  @override
  String reminderLabel(String label) {
    return 'Lembrete: $label';
  }

  @override
  String get couldNotLaunchEmail =>
      'Não foi possível abrir o cliente de e-mail';

  @override
  String get couldNotOpenPlayStore =>
      'Não foi possível abrir a Google Play Store';

  @override
  String get inviteShareSubject => 'Experimente o app Secure Notepad';

  @override
  String get inviteShareText =>
      'Confira este incrível app Secure Notepad! Ele me ajuda a organizar e proteger minhas notas.\n\nBaixe aqui: https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app&pli=1';

  @override
  String get setUpPassword => 'Configurar senha';

  @override
  String get setPassword => 'Definir senha';

  @override
  String get selectSecurityQuestion => 'Selecionar pergunta de segurança';

  @override
  String get answer => 'Resposta';

  @override
  String get save => 'Salvar';

  @override
  String get pleaseFillAllFields => 'Preencha todos os campos';

  @override
  String get passwordSecuritySet => 'Senha e pergunta de segurança definidas';

  @override
  String get enterPassword => 'Digite a senha';

  @override
  String get password => 'Senha';

  @override
  String get submit => 'Enviar';

  @override
  String get forgotPassword => 'Esqueci a senha';

  @override
  String get error => 'Erro';

  @override
  String get securityQuestionNotSet => 'Pergunta de segurança não definida';

  @override
  String get ok => 'OK';

  @override
  String get securityQuestion => 'Pergunta de segurança';

  @override
  String get incorrectPassword => 'Senha incorreta';

  @override
  String get incorrectAnswer => 'Resposta incorreta';

  @override
  String get verify => 'Verificar';

  @override
  String get resetPassword => 'Redefinir senha';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get pleaseEnterNewPassword => 'Digite uma nova senha';

  @override
  String get passwordResetSuccess => 'Senha redefinida com sucesso';

  @override
  String get noLockedNotesYet => 'Nenhuma nota bloqueada ainda.';

  @override
  String get noLockedNotesMatchSearch =>
      'Nenhuma nota bloqueada corresponde à sua pesquisa.';

  @override
  String get securitySetup => 'Configuração de segurança';

  @override
  String get setUpSecurityQuestion => 'Configurar pergunta de segurança';

  @override
  String get selectSecurityQuestionPrompt =>
      'Selecione uma pergunta de segurança:';

  @override
  String get saveSecuritySetup => 'Salvar configuração de segurança';

  @override
  String get pleaseSelectQuestionAndAnswer =>
      'Selecione uma pergunta e forneça uma resposta';

  @override
  String get securitySetupCompleted => 'Configuração de segurança concluída';

  @override
  String get securityQuestionDob => 'Qual é a sua data de nascimento?';

  @override
  String get securityQuestionFood => 'Qual é a sua comida favorita?';

  @override
  String get securityQuestionPlace => 'Qual é o seu lugar favorito?';

  @override
  String get batchNotes => 'Notas em lote';

  @override
  String get addTask => 'Adicionar tarefa';

  @override
  String get editTask => 'Editar tarefa';

  @override
  String get saveBatchNote => 'Salvar nota em lote';

  @override
  String get noBatchNotesYet => 'Nenhuma nota em lote ainda.';

  @override
  String get noteDeleted => 'Nota excluída';

  @override
  String errorMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String errorDeletingNote(String message) {
    return 'Erro ao excluir nota: $message';
  }

  @override
  String get taskReminder => 'Lembrete de tarefa';

  @override
  String get taskReminderCleared => 'Lembrete de tarefa removido';

  @override
  String get taskReminderClearedSave =>
      'Lembrete de tarefa removido. Salve a nota para manter as alterações.';

  @override
  String get taskReminderSetSave =>
      'Lembrete de tarefa definido. Salve a nota para ativá-lo.';

  @override
  String taskReminderSet(String label) {
    return 'Lembrete de tarefa: $label';
  }

  @override
  String couldNotSaveTaskReminder(String message) {
    return 'Não foi possível salvar o lembrete: $message';
  }

  @override
  String get editTaskReminder => 'Editar lembrete de tarefa';

  @override
  String get setTaskReminder => 'Definir lembrete de tarefa';

  @override
  String get setReminder => 'Definir lembrete';

  @override
  String get repeat => 'Repetir';

  @override
  String get once => 'Uma vez';

  @override
  String get daily => 'Diário';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get date => 'Data';

  @override
  String get startDate => 'Data de início';

  @override
  String get time => 'Hora';

  @override
  String get clear => 'Limpar';

  @override
  String get reminderCleared => 'Lembrete removido';

  @override
  String get pleaseChooseFutureDateTime => 'Escolha uma data e hora futuras';

  @override
  String get couldNotScheduleReminder =>
      'Não foi possível agendar o lembrete. Permita notificações e alarmes nas configurações.';

  @override
  String reminderSet(String label) {
    return 'Lembrete definido: $label';
  }

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String get setReminderAction => 'Definir lembrete';

  @override
  String moreTasks(int count) {
    return '+ $count tarefas a mais';
  }

  @override
  String get install => 'Instalar';

  @override
  String get moreAppsComingSoon => 'Mais apps em breve.\nVolte mais tarde!';

  @override
  String get seeNotesOnHomeScreen => 'Veja suas notas na tela inicial';

  @override
  String get widgetDescription =>
      'O widget mostra suas 5 notas mais recentes e abre o app ao tocar. Atualiza automaticamente quando você adiciona ou edita notas.';

  @override
  String get widgetInstalled => 'O widget está na sua tela inicial';

  @override
  String get addWidgetToHomeScreen => 'Adicionar widget à tela inicial';

  @override
  String get showHowToAddWidget => 'Como adicionar widget';

  @override
  String get refreshWidgetNow => 'Atualizar widget agora';

  @override
  String get howToAddManually => 'Como adicionar manualmente';

  @override
  String get widgetStep1 => 'Vá para a tela inicial do celular';

  @override
  String get widgetStep2 => 'Pressione e segure em um espaço vazio';

  @override
  String get widgetStep3 => 'Toque em Widgets';

  @override
  String get widgetStep4 => 'Encontre \"Secure Notepad Notes\"';

  @override
  String get widgetStep5 => 'Arraste para a tela inicial';

  @override
  String get widgetOldDataTip =>
      'Se o widget mostrar dados antigos, abra o app uma vez ou toque em \"Atualizar widget agora\" acima.';

  @override
  String get addWidgetManually => 'Adicionar widget manualmente';

  @override
  String get widgetManualDialogContent =>
      '1. Vá para a tela inicial do celular\n2. Pressione e segure em um espaço vazio\n3. Toque em Widgets\n4. Encontre \"Secure Notepad Notes\"\n5. Arraste para a tela inicial';

  @override
  String get gotIt => 'Entendi';

  @override
  String get confirmAddWidget =>
      'Confirme a adição do widget quando o celular solicitar.';

  @override
  String get couldNotOpenWidgetPicker =>
      'Não foi possível abrir o seletor de widgets. Use os passos manuais abaixo.';

  @override
  String couldNotAddWidget(String message) {
    return 'Não foi possível adicionar o widget: $message';
  }

  @override
  String get widgetRefreshed => 'Widget da tela inicial atualizado';

  @override
  String get couldNotRefreshWidgetRetry =>
      'Não foi possível atualizar o widget. Abra o app e tente novamente.';

  @override
  String couldNotRefreshWidget(String message) {
    return 'Não foi possível atualizar o widget: $message';
  }

  @override
  String couldNotLoadWidgetStatus(String message) {
    return 'Não foi possível carregar o status do widget: $message';
  }

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String get stopVoiceInput => 'Parar entrada de voz';

  @override
  String get micPermissionRequired =>
      'A permissão do microfone é necessária para entrada de voz.';

  @override
  String get micPermissionDeniedSettings =>
      'Permissão do microfone negada. Ative nas configurações do app.';

  @override
  String get voiceInputNotAvailable =>
      'Entrada de voz não disponível neste dispositivo.';

  @override
  String dailyAt(String time) {
    return 'Diariamente às $time';
  }

  @override
  String weeklyOn(String day, String time) {
    return 'Semanalmente às $day às $time';
  }

  @override
  String monthlyOnDay(String day, String time) {
    return 'Mensalmente no dia $day às $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date às $time';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Bloco de Notas Seguro';

  @override
  String get searchNotes => 'Pesquisar notas';

  @override
  String get searchLockedNotes => 'Pesquisar notas bloqueadas';

  @override
  String get batchMode => 'Modo em lote';

  @override
  String get lockedNotes => 'Notas bloqueadas';

  @override
  String get homeScreenWidget => 'Widget da tela inicial';

  @override
  String get ourNewApps => 'Nossos novos apps';

  @override
  String get inviteFriends => 'Convidar amigos para o app';

  @override
  String get sendFeedback => 'Enviar feedback';

  @override
  String get rateUs => 'Avaliar';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get languageChanged => 'Idioma atualizado';

  @override
  String get english => 'Inglês';

  @override
  String get hindi => 'Hindi';

  @override
  String get spanish => 'Espanhol';

  @override
  String get french => 'Francês';

  @override
  String get indonesian => 'Indonésio';

  @override
  String get brazilianPortuguese => 'Português (Brasil)';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get addNotesToHomeScreen => 'Adicione notas à tela inicial';

  @override
  String get widgetTipDescription =>
      'Fixe um widget para ver suas notas recentes sem abrir o app.';

  @override
  String get setUpWidget => 'Configurar widget';

  @override
  String get dismiss => 'Fechar';

  @override
  String get title => 'Título';

  @override
  String get content => 'Conteúdo';

  @override
  String get addNote => 'Adicionar nota';

  @override
  String get updateNote => 'Atualizar nota';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteNote => 'Excluir nota';

  @override
  String get deleteNoteConfirm =>
      'Tem certeza de que deseja excluir esta nota?';

  @override
  String get delete => 'Excluir';

  @override
  String get noteAdded => 'Nota adicionada';

  @override
  String get noteUpdated => 'Nota atualizada';

  @override
  String get noNotesYet => 'Nenhuma nota ainda.';

  @override
  String get noNotesMatchSearch => 'Nenhuma nota corresponde à sua pesquisa.';

  @override
  String reminderLabel(String label) {
    return 'Lembrete: $label';
  }

  @override
  String get couldNotLaunchEmail =>
      'Não foi possível abrir o cliente de e-mail';

  @override
  String get couldNotOpenPlayStore =>
      'Não foi possível abrir a Google Play Store';

  @override
  String get inviteShareSubject => 'Experimente o app Secure Notepad';

  @override
  String get inviteShareText =>
      'Confira este incrível app Secure Notepad! Ele me ajuda a organizar e proteger minhas notas.\n\nBaixe aqui: https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app&pli=1';

  @override
  String get setUpPassword => 'Configurar senha';

  @override
  String get setPassword => 'Definir senha';

  @override
  String get selectSecurityQuestion => 'Selecionar pergunta de segurança';

  @override
  String get answer => 'Resposta';

  @override
  String get save => 'Salvar';

  @override
  String get pleaseFillAllFields => 'Preencha todos os campos';

  @override
  String get passwordSecuritySet => 'Senha e pergunta de segurança definidas';

  @override
  String get enterPassword => 'Digite a senha';

  @override
  String get password => 'Senha';

  @override
  String get submit => 'Enviar';

  @override
  String get forgotPassword => 'Esqueci a senha';

  @override
  String get error => 'Erro';

  @override
  String get securityQuestionNotSet => 'Pergunta de segurança não definida';

  @override
  String get ok => 'OK';

  @override
  String get securityQuestion => 'Pergunta de segurança';

  @override
  String get incorrectPassword => 'Senha incorreta';

  @override
  String get incorrectAnswer => 'Resposta incorreta';

  @override
  String get verify => 'Verificar';

  @override
  String get resetPassword => 'Redefinir senha';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get pleaseEnterNewPassword => 'Digite uma nova senha';

  @override
  String get passwordResetSuccess => 'Senha redefinida com sucesso';

  @override
  String get noLockedNotesYet => 'Nenhuma nota bloqueada ainda.';

  @override
  String get noLockedNotesMatchSearch =>
      'Nenhuma nota bloqueada corresponde à sua pesquisa.';

  @override
  String get securitySetup => 'Configuração de segurança';

  @override
  String get setUpSecurityQuestion => 'Configurar pergunta de segurança';

  @override
  String get selectSecurityQuestionPrompt =>
      'Selecione uma pergunta de segurança:';

  @override
  String get saveSecuritySetup => 'Salvar configuração de segurança';

  @override
  String get pleaseSelectQuestionAndAnswer =>
      'Selecione uma pergunta e forneça uma resposta';

  @override
  String get securitySetupCompleted => 'Configuração de segurança concluída';

  @override
  String get securityQuestionDob => 'Qual é a sua data de nascimento?';

  @override
  String get securityQuestionFood => 'Qual é a sua comida favorita?';

  @override
  String get securityQuestionPlace => 'Qual é o seu lugar favorito?';

  @override
  String get batchNotes => 'Notas em lote';

  @override
  String get addTask => 'Adicionar tarefa';

  @override
  String get editTask => 'Editar tarefa';

  @override
  String get saveBatchNote => 'Salvar nota em lote';

  @override
  String get noBatchNotesYet => 'Nenhuma nota em lote ainda.';

  @override
  String get noteDeleted => 'Nota excluída';

  @override
  String errorMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String errorDeletingNote(String message) {
    return 'Erro ao excluir nota: $message';
  }

  @override
  String get taskReminder => 'Lembrete de tarefa';

  @override
  String get taskReminderCleared => 'Lembrete de tarefa removido';

  @override
  String get taskReminderClearedSave =>
      'Lembrete de tarefa removido. Salve a nota para manter as alterações.';

  @override
  String get taskReminderSetSave =>
      'Lembrete de tarefa definido. Salve a nota para ativá-lo.';

  @override
  String taskReminderSet(String label) {
    return 'Lembrete de tarefa: $label';
  }

  @override
  String couldNotSaveTaskReminder(String message) {
    return 'Não foi possível salvar o lembrete: $message';
  }

  @override
  String get editTaskReminder => 'Editar lembrete de tarefa';

  @override
  String get setTaskReminder => 'Definir lembrete de tarefa';

  @override
  String get setReminder => 'Definir lembrete';

  @override
  String get repeat => 'Repetir';

  @override
  String get once => 'Uma vez';

  @override
  String get daily => 'Diário';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get date => 'Data';

  @override
  String get startDate => 'Data de início';

  @override
  String get time => 'Hora';

  @override
  String get clear => 'Limpar';

  @override
  String get reminderCleared => 'Lembrete removido';

  @override
  String get pleaseChooseFutureDateTime => 'Escolha uma data e hora futuras';

  @override
  String get couldNotScheduleReminder =>
      'Não foi possível agendar o lembrete. Permita notificações e alarmes nas configurações.';

  @override
  String reminderSet(String label) {
    return 'Lembrete definido: $label';
  }

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String get setReminderAction => 'Definir lembrete';

  @override
  String moreTasks(int count) {
    return '+ $count tarefas a mais';
  }

  @override
  String get install => 'Instalar';

  @override
  String get moreAppsComingSoon => 'Mais apps em breve.\nVolte mais tarde!';

  @override
  String get seeNotesOnHomeScreen => 'Veja suas notas na tela inicial';

  @override
  String get widgetDescription =>
      'O widget mostra suas 5 notas mais recentes e abre o app ao tocar. Atualiza automaticamente quando você adiciona ou edita notas.';

  @override
  String get widgetInstalled => 'O widget está na sua tela inicial';

  @override
  String get addWidgetToHomeScreen => 'Adicionar widget à tela inicial';

  @override
  String get showHowToAddWidget => 'Como adicionar widget';

  @override
  String get refreshWidgetNow => 'Atualizar widget agora';

  @override
  String get howToAddManually => 'Como adicionar manualmente';

  @override
  String get widgetStep1 => 'Vá para a tela inicial do celular';

  @override
  String get widgetStep2 => 'Pressione e segure em um espaço vazio';

  @override
  String get widgetStep3 => 'Toque em Widgets';

  @override
  String get widgetStep4 => 'Encontre \"Secure Notepad Notes\"';

  @override
  String get widgetStep5 => 'Arraste para a tela inicial';

  @override
  String get widgetOldDataTip =>
      'Se o widget mostrar dados antigos, abra o app uma vez ou toque em \"Atualizar widget agora\" acima.';

  @override
  String get addWidgetManually => 'Adicionar widget manualmente';

  @override
  String get widgetManualDialogContent =>
      '1. Vá para a tela inicial do celular\n2. Pressione e segure em um espaço vazio\n3. Toque em Widgets\n4. Encontre \"Secure Notepad Notes\"\n5. Arraste para a tela inicial';

  @override
  String get gotIt => 'Entendi';

  @override
  String get confirmAddWidget =>
      'Confirme a adição do widget quando o celular solicitar.';

  @override
  String get couldNotOpenWidgetPicker =>
      'Não foi possível abrir o seletor de widgets. Use os passos manuais abaixo.';

  @override
  String couldNotAddWidget(String message) {
    return 'Não foi possível adicionar o widget: $message';
  }

  @override
  String get widgetRefreshed => 'Widget da tela inicial atualizado';

  @override
  String get couldNotRefreshWidgetRetry =>
      'Não foi possível atualizar o widget. Abra o app e tente novamente.';

  @override
  String couldNotRefreshWidget(String message) {
    return 'Não foi possível atualizar o widget: $message';
  }

  @override
  String couldNotLoadWidgetStatus(String message) {
    return 'Não foi possível carregar o status do widget: $message';
  }

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String get stopVoiceInput => 'Parar entrada de voz';

  @override
  String get micPermissionRequired =>
      'A permissão do microfone é necessária para entrada de voz.';

  @override
  String get micPermissionDeniedSettings =>
      'Permissão do microfone negada. Ative nas configurações do app.';

  @override
  String get voiceInputNotAvailable =>
      'Entrada de voz não disponível neste dispositivo.';

  @override
  String dailyAt(String time) {
    return 'Diariamente às $time';
  }

  @override
  String weeklyOn(String day, String time) {
    return 'Semanalmente às $day às $time';
  }

  @override
  String monthlyOnDay(String day, String time) {
    return 'Mensalmente no dia $day às $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date às $time';
  }
}
