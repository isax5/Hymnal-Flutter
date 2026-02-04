# Hymnal app by IA

I need to make an hymnal app. This app will work on Spanish, English, Russian and Portuguese

## App files description:

In info_constants.json you can find the name of the hymnbook, language, year, hymns file with the lyrics, thematic list and sheets file name

- json files with lyrics and thematic list are inside hymns folder
- The piano sheets are inside the musicSheets folder
  - If the hymn as musicSheet it will say in the info_constants.json file as hymnsSheetsFileName. You need to replace the ### with the number of the hymn using the number format 001, 002….. 101, 102, …. etc
  - Some hymns are so long that have even up to 6 pictures and the need to go in order 001, 001_1, 001_2, 001_3 etc…..
    - A good example of that is the piano_sheet_ru_370.png, piano_sheet_ru_370_1.png, piano_sheet_ru_370_2.png and piano_sheet_ru_370_3.png
    - Other example is: piano_sheet_en_663.png, piano_sheet_en_663_1.png, piano_sheet_en_663_2.png, piano_sheet_en_663_3.png, piano_sheet_en_663_4.png and piano_sheet_en_663_5.png

In settings.json you can find using the same id as in info_constants.json the instrumental music and the sung music url, this url will guide you to the mp3 file to stream with the audio of the hymn. To make it work just replace the ### with the number of the hymn using the number format 001, 002, 003, ……. 100, 101, 102…. etc..

## App navigation description:

The app contains different pages to provide the best user experience

- Tabbed page: it is the basic part of the app
  - Home page: you can introduce the number and open the hymn: it need to make sure that the hymn exist becase the user can introduce any number. It important that the user also get aware of with hymnbook he is using because the are users that switch between versions because they are in a bilingual environment. We can add some label to show the hymnbook currently selected
    - Search page: From here also there is a button to open search page and it allows to look for an hymn writing the title, lyrics, etc.. only of the selected hymnbook because if im in Spanish hymnbook I will not look for the English or Russian
    - Record: It shows the last 50 hymns opened. It doesn’t care about the hymnbook you have in the moment, it’s just the las 50 hymns. The 50 number need to be a constant in the constant file of the app
    - Hymn: obviously from here you can open an hymn when you introduce the number and press on open
  - Lists: this page allows you to list the hymns by alphabetic order, numeric order and thematic
    - In case its thematic you need to navigate to the ambit page
      - When you open the ambit then you see the list of hymns that are included in this ambit
  - Favorites: all hymns that are saved as favorites need to be in the favorites list, this is just a list and you can order the hymns as you want. Favorites are storage locally so you reed the data from there
  - Settings: this is just a page of settings where you can select different hymnbooks, adjust the lyrics size inside the hymn page, select if you want to use dark mode, light mode or automatic, keep screen always on when using the app, if to show the background image behind the lyrics, allows you to open the git repository to contribute in the project, it will show the app version and app build number too. For sure is good idea to add the flutter page that shows the used packages

- Hymn page: this page shows the lyrics of the hymn and it will be open from home, list, favorites, search and records. To mark a hymn as favorite you can select it in this page and remove it from there too.. I want to be able to share the hymn here and play the music if the hymn with a simple play button. This page also will allow you to scroll to the side and open other hymns, for example, if you open the hymn number 11, scrolling to the right you can find the hymn number 10 and scrolling to the left you see the hymn number 12
  - Inside the hymn page you can open the piano sheets in case this hymn has a piano sheet. To know if there is a piano sheet you should check on info_constants.json looking for hymnsSheetsFileName attribute

- It will be nice to have a media player page, I don’t know how to call it, but to be able to play one hymn and it will show in the button of the app the option to open the player page, in this page you can operate like in any other media player, move forward, continue playing other hymns after, etc… and it should show the number and name of the hymn that is been playing and of course the option to open that hymn again to see the lyrics. I need to work in background when minimizing the app

## App files:

Make order in the repository when creating the project

app_icon.svg is the file to use as icon and splash screen. Make the stuffs accordingly

## Considerations:

I recommend to use icon form google like the ones included in flutter

- If the user has English language currently on the phone, the app the first time that the user opens it will select the first English hymnbook in info_constants.json
- The app website is: https://isax5.github.io/hymnal/
- The repository for contributions is: https://github.com/isax5/Hymnal-Xamarin
- AppStore link is: https://apps.apple.com/cl/app/adventist-hymnal/id1153114394
- The PlayStore link: https://play.google.com/store/apps/details?id=net.ddns.HimnarioAdventistaSPA
- It will be nice to recommend the user to give a calification in the stores time to time
- The settings.json file need to be taken from https://isax5.github.io/hymnal/backend-data/v1/settings.json . In this case is included in the folder just for convenience
