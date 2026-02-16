// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Hinário';

  @override
  String get home => 'Início';

  @override
  String get lists => 'Listas';

  @override
  String get favorites => 'Favoritos';

  @override
  String get settings => 'Ajustes';

  @override
  String get history => 'Histórico';

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar hinos...';

  @override
  String get noHymnsFound => 'Nenhum hino encontrado';

  @override
  String get numeric => 'Numérico';

  @override
  String get alpha => 'Alfabético';

  @override
  String get thematic => 'Temático';

  @override
  String get selectedHymnal => 'Hinário selecionado';

  @override
  String get selectHymnal => 'Selecionar hinário';

  @override
  String get welcomeTitle => 'Bem-vindo ao App Hinário';

  @override
  String get welcomeSubtitle => 'Selecione um hinário para começar';

  @override
  String get hymnNumber => 'Número do Hino';

  @override
  String get enterHymnNumber => 'Digite o número do hino';

  @override
  String get openHymn => 'Abrir Hino';

  @override
  String get go => 'Ir';

  @override
  String get invalidHymnNumber => 'Por favor, digite un número de hino válido';

  @override
  String get hymnNotFound => 'Hino não encontrado';

  @override
  String get hymnalNotSelected => 'Nenhum hinário selecionado';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get clearHistoryConfirm =>
      'Tem certeza de que deseja limpar o histórico? Esta ação não pode ser desfeita.';

  @override
  String get historyCleared => 'Histórico limpo';

  @override
  String get clearFavorites => 'Limpar favoritos';

  @override
  String get clearFavoritesConfirm =>
      'Tem certeza de que deseja limpar todos os favoritos? Esta ação não pode ser desfeita.';

  @override
  String get favoritesCleared => 'Favoritos limpos';

  @override
  String get noFavoritesYet => 'Ainda não há favoritos';

  @override
  String get addHymnsToFavorites =>
      'Adicione hinos aos seus favoritos na página do hino';

  @override
  String get noHistoryYet => 'Ainda não há histórico';

  @override
  String removeFavorite(String title) {
    return 'Remover \"$title\" dos favoritos?';
  }

  @override
  String get removeFavoriteTitle => 'Remover Favorito';

  @override
  String removedFromFavorites(String title) {
    return '$title removido dos favoritos';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get undo => 'Desfazer';

  @override
  String get actionReversed => 'Ação revertida';

  @override
  String hymnRange(int start, int end) {
    return 'Hinos $start-$end';
  }

  @override
  String get appearance => 'Aparência';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get fontSize => 'Tamanho da fonte';

  @override
  String get backgroundImage => 'Imagem de fondo';

  @override
  String get showBackgroundImage => 'Mostrar imagem de fondo';

  @override
  String get playback => 'Reprodução';

  @override
  String get keepScreenOn => 'Manter tela ligada';

  @override
  String get keepScreenOnDesc => 'Não escurecer ou desligar a tela';

  @override
  String get continuousPlay => 'Reprodução contínua';

  @override
  String get data => 'Dados';

  @override
  String get clearHistoryDesc =>
      'Remover todos os hinos visualizados recentemente';

  @override
  String get clearFavoritesDesc => 'Remover todos os hinos favoritos';

  @override
  String get about => 'Sobre';

  @override
  String get website => 'Site';

  @override
  String get contribute => 'Contribuir';

  @override
  String get repository => 'Repositório GitHub';

  @override
  String get rateApp => 'Avaliar o App';

  @override
  String get version => 'Versão';

  @override
  String get licenses => 'Licenças';

  @override
  String sheetMusicTitle(int number) {
    return 'Partitura - Hino $number';
  }

  @override
  String failedToLoadImage(String error) {
    return 'Falha ao carregar a imagem: $error';
  }

  @override
  String get noSheetMusicAvailable =>
      'Nenhuma partitura disponível para este hinário';

  @override
  String noSheetMusicFound(int number) {
    return 'Nenhuma partitura encontrada para o hino $number';
  }

  @override
  String get share => 'Compartilhar';

  @override
  String get viewLyrics => 'Ver letra';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get sung => 'Cantado';

  @override
  String get hymnalLanguage => 'Idioma';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get clear => 'Limpar';

  @override
  String hymnTitle(int number) {
    return 'Hino $number';
  }

  @override
  String get sharedFromApp => 'Compartilhado do App Hinário';

  @override
  String get nowPlaying => 'Reproduzindo agora';

  @override
  String get noAudioPlaying => 'Nenhum áudio tocando';

  @override
  String get sectionHymnal => 'Hinário';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get sectionBehavior => 'Comportamento';

  @override
  String get sectionDataManagement => 'Gerenciamento de dados';

  @override
  String get sectionAbout => 'Sobre';

  @override
  String get backgroundImageSubtitle => 'Mostrar imagem de fundo nas telas';

  @override
  String get clearHistorySubtitle =>
      'Remover todos os hinos vistos recentemente';

  @override
  String get clearFavoritesSubtitle => 'Remover todos os hinos favoritos';

  @override
  String get githubRepo => 'Repositório GitHub';

  @override
  String get none => 'Nenhum';
}
