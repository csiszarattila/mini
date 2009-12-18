---
id: 11
author: Csiszár Attila
title: "Zend Framework: Zend_Application + Bootstrap + Resource"
created_at: 2009-12-18
image_path: zflogo.png
---

[github]: http://github.com/csiszarattila/zendframework_base "A projekt Github oldala"
[part1]: /rubysztan/cikkek/zend_bootstrap "Zend_Framework bootstrap"
[part2]: /rubysztan/cikkek/zend_doctrine_1_2_integracio "Leírás a Zend_Framework-Doctrine integrációról"

A következő a cikksorozatokban - a Rubysztán blog történetében először - PHP-s témára kerül a sor, méghozzá a mostanság két legdivatosabb library, a Zend keretrendszer és a Doctrine összehangolására. Railsszel fejlesztők figyelem: jöhet egy kis Zend vs. Rails összehasonlítás:)

Az alábbi példakódok az elmúlt időszakban tett erőfeszítéseim eredményei, amelyben általános, több célra felhasználható Zend keretrendszerre épülő alkalmazás-váz létrehozását tűztem ki célul.

A példakódok követhetőek vagy teljes alkalmazás-váz letölthető [a projekt Github oldaláról][github].

A sorozat első részeként egy, a Zend keretrendszerre épülő MVC alkalmazásváz létrehozása, a bootstrappelés és a hozzá kapcsolódó fogalmak kerülnek bemutatásra. A folytatás a [Doctrine 1.2-es verziójának integráció][part2]járól szól.

## Bootstrap a Zend Application-el

A Zend 1.8-as verziói előtt az alkalmazás indítása finoman szólva is eléggé hektikus területnek számított. Mivel a Zend keretrendszer moduláris felépítésűnek született, azzal az ötlettel, hogy a fejlesztőknek a legnagyobb szabadságot biztosítsa, a keretrendszer bootstrappelésére sem adott igazán egységes megoldást. Ez csak egy eredményhez: a tökéletes káoszhoz vezethetett. Félmegoldások és ötletek születtek, kinek ez, kinek az a megoldás működött - sajnos fejlesztőként a mindennapok során még nekem is ezekkel a katasztrófális megoldásokkal kell megbírkóznom.

Az 1.8-as verzió megjelenése azonban magával hozta a Zend_Application osztályt, és vele együtt a korábbi gondok megoldását, hiszen ez lehetővé teszi, hogy egységes és objektumorientált módon, egy osztályon keresztül végezhessük az alkalmazás bootstrappelését és konfigurációját. A megoldás fokozatosan finomodott, és véleményem szerint az egyik leghasznosabb fejlődést hozta hosszú idő óta a Zend keretrendszerbe.

Az alkalmazás indítása annyira legegyszerűsödött, hogy mindössze egy Zend_Application példányt kell létrehoznunk, amely két paramétert vár: a környezetét, és egy konfigurációs fájlt.

A példányosítást megtehetjük az alkalmazás belépő pontján, ez az én esetemben a public/index.php fájl - minden kérést ide fut be:

_A public könyvtárba csak azoknak a fájloknak szabad kerülniük, amelyeket a webszervernek statikusan kell kiszolgánia, minden alkalmazásbeli logika ettől elválasztva, az application könyvtárba kerül._

    # public/index.php
    $application = new Zend_Application(
      APP_ENV,
      APPLICATION_ROOT . '/config/application.ini'
    );

    $application->bootstrap()->run();
    
A fenti kódsor használatához természetesen előbb szükségünk van:

1.  A megfelelő osztályok eléréséhez, és néhány fontosabb útvonal definiálásához:
    
    Én ezeket egy külön fájlban (__config/include_paths.php__) helyeztem el, amit szükséges esetben beincludolva fel tudok használni. 
    
    _Itt adom hozzá az include_path-okhoz a Zend keretrendszer library/ könyvtárának elérését is, különben a public/index.php fájlban hiába hivatkoznék a Zend_Application osztályra._
  
2.  A környezet megállapítása:
    
    Ezt egyszerűen az APP_ENV környezeti változóból veszem, amely így bárhol beállíthatóvá válik:
 
    * Apache direktívával:
      
      SetEnv APP_ENV development
 
    * Parancssorból:
      
      export APP_ENV=development
 
    * Futás alatt PHP-ben:
      
      setenv('APP_ENV', 'development');
      getenv('APP_ENV');
    
Így adott esetben könnyedén megváltoztathatom az alkalmazás futtatási környezetét ami lehetővé teszi, hogy eltérő beállításokat alkalmazzunk bizonyos helyezetekben: egy fejlesztői és egy éles rendszer szinte biztosan teljesen más beállításokat követel meg.

Az alkalmazandó beállításokat az Zend\_Application a példányosításakor átadott konfigurációs állományból olvassa ki. Környezetet ebben - a PHP ini formátumú sémáiban megszokott módon - a _[]_ jelek között hozhatunk létre (pl. \[production] ). 

Szerencsére a Zend keretrendszer konfigurációjó lehetővé tesz olyan alapvető dolgokat, mint a beállítások egymásból származtatása, felülbírálása. Én személy szerint azt a konvenciót követem, hogy minden alapbeállítást egy \[default] címkével látok el, amelyet a további környezetek kiterjeszthetnek, így a szükséges beállítások egyszerűen felüldefiniálhatóak. Leszármaztatást a _:_ jellel adhatjuk meg. Az alábbi példában az production(éles) környezet mindenben a default beállítasait használja, kivéve, hogy a regisztrációkról szóló értesítéseket egy másik címre irányítom át.

    [default]
    email.registration.email_to = csiszar.ati@gmail.com

    [production : default]
    email.registration.email_to = administrator@example.com

A konfiguráció beolvasása után az alkalmazás felállítása a bootstrappeléssel folytatódik, amelyet a következő kódsor hív meg:

    $application->bootstrap();


## Bootstrap, Bootstrap osztály és a Bootstrap Resource-ok

A Zend_Application a bootstrap során a konfigurációban megadott Bootstrap osztályhoz fordul, amely egyszerűen lefordítva futtat minden benne megadott _init prefixszel kezdődő metódust. 

Például az _initView metódus a nézetekhez tartozó alapvető feladatokat definiálhatja, és elvégzi bizonyos paraméterek beállítását:

    # application/Bootstrap.php
    public function _initView()
    {
      $viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
      $viewRenderer->initView();
      $viewRenderer->view->doctype('XHTML1_TRANSITIONAL');
    }

A bootstrappelést ugyanakkor egyszerűbbé tehetjük, ha a fentihez hasonló metódusokat külön osztályokban, a Zend terminilógiájában úgynevezett erőforrás plugineken keresztül valósítjuk meg. Az erőforrások használatával a bootstrappelés modulárisabbá tehető: a gyakran használt erőforrások könnyedén átvihetőek lesznek egyik alkalmazásból a másikba.

Erőforrás létrehozásához a Zend_Application_Resource_ResourceAbstract absztrakt osztályt kell megvalósítanunk. 

A fenti példa valahogy így nézne ki erőforráskét megvalósítva:

    class zf_Application_Resource_XhtmlView extends Zend_Application_Resource_ResourceAbstract
    {
  
      public function init()
      {
        $viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
        $viewRenderer->initView();
        $viewRenderer->view->doctype('XHTML1_TRANSITIONAL');
      }
    }

Használatához az alkalmazás konfigurációjában PluginPath útvonalként kell regisztrálnunk az elérését:

    # application.ini
    pluginPaths.custom_resources = LIBRARY_PATH "/zf/Application/Resource"

Az erőforrás osztály automatikus meghívását a bootstrap során egy hozzá kapcsolódó beállítás megadásával érhetjük el, amit könnyedén elérhetünk, hiszen a resources tömbön keresztül lehetőségünk van rá hivatkozni:

    resources.xhtmlview.[]

Ebből következik,hogy mivel a bootstrap során az alap építőelemeit (a MVC mintához elengedhetetlen FrontController, View, Router stb. elemeket) a Zend keretrendszer maga is ilyen Resource-okon keresztül hívja meg, a konfigurációs állományból ezek rendkívül könnyen konfigurálhatóak lesznek. Az alábbi példában például egyszerűen meg tudom adni az MVC mintában elengedhetetlen controller osztályok elérését:

    resources.frontController.controllerDirectory = APPLICATION_PATH "/controllers"
    
Ha mindezzel megvagyunk következhet az MVC M része, azaz a modellek kezelése, amelyre én a Doctrine ORM-t használtam fel.

A Zend_Framework - Doctrine integrációjáról [a folytatásban olvashatsz][part2].

## A sorozatban eddig megjelent

[Zend Framework: Zend_Application + Bootstrap + Resource][part1]

[Zend Framework: Doctrine 1.2 integrálása][part2]