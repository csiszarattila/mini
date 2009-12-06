---
id: 11
author: Csiszár Attila
title: "Zend Framework: Zend_Application + Bootstrap + Resource"
created_at: 2009-12-06
image_path: zflogo.jpg
---

A következő a cikksorozatokban - a Rubysztán blog történetében először - PHP-s témára kerül a sor, méghozzá a mostanság két legdivatosabb library, a Zend keretrendszer és a Doctrine összehangolására. Railsszel fejlesztők figyelem: jöhet egy kis Zend vs. Rails összehasonlítás:)

Az alábbi példakódok az elmúlt időszakban tett erőfeszítéseim eredményei, amelyben egy minden célra felhasználható, a Zend keretrendszerre épülő alkalmazás váz létrehozása a cél.

A példakódok követéséhez a Githubról elérhető forrás megtekintését ajánlom. http://github.com/csiszarattila/zendframework_base

A sorozat első részeként egy, a Zend keretrendszerre épülő MVC alkalmazásváz létrehozása, a bootstrappelés és a hozzá kapcsolódó fogalmak kerülnek bemutatásra. A folytatásban a Doctrine 1.2-es változatának integrációja került terítékre.

## Bootstrap a Zend Application-el

A Zend 1.8-as verziói előtt az alkalmazás indítása finoman szólva is eléggé hektikus területnek számított. Mivel a Zend keretrendszer moduláris felépítésűnek született, azzal az ötlettel, hogy a fejlesztőknek a legnagyobb szabadságot biztosítsa, a keretrendszer bootstrappelésére sem adott igazán egységes megoldást. Ez csak egy eredményhez, a tökéletes káoszhoz vezethetett: félmegoldások és ötletek születtek, kinek ez, kinek az a megoldás működött - sajnos fejlesztőként a mindennapok során még nekem is ezekkel a szörnyű megoldásokkal kell megbírkóznom.

Az 1.8-as verzió megjelenése azonban megoldotta ezeket a gondokat, hiszen megjelent a Zend_Application osztály, amely lehetővé tette, hogy egységes és objektumorientált módon, egy osztályon keresztül végezhessük az alkalmazás bootstrappelését és konfigurációját. A megoldás idővel fokozatosan finomodott, és véleményem szerint az egyik leghasznosabb fejlődést hozta hosszú idő óta a Zend keretrendszerbe.

Az alkalmazás indítása annyira legegyszerűsödött, hogy mindössze egy Zend_Application példányt kell létrehoznunk, amely két paramétert vár: a környezetét, és egy konfigurációs fájlt.

Ezt megtehetjük az alkalmazás belépő pontján, amely az én esetemben a public/index.php fájl szolgál:
_A public könyvtáramba csak azok a fájlok kerülnek, amelyeket a webszervernek statikusan kell kiszolgánia._

    # public/index.php
    $application = new Zend_Application(
      APPLICATION_ENV,
      APPLICATION_ROOT . '/config/application.ini'
    );

    $application->bootstrap()->run();
    
A Zend_Application használatához természetesen szükségünk van:

1. A megfelelő osztályok eléréséhez, és néhány fontosabb útvonal definiálásához:
    Én ezeket egy külön fájlban (config/include_paths.php) helyeztem el, amit szükséges esetben beincludolva fel tudok használni. 
    _Itt adom hozzá az include_path-okhoz a Zend keretrendszer library könyvtárának elérését is, különben az public/index.php-ban hiába hivatkoznék a Zend_Application osztályra_
  
2. A környezet megállapítása:
 Ezt egyszerűen az APP_ENV környezeti változóból veszem, amely így bárhol beállíthatóvá válik:
 
 * Apache direktívával:
    
    SetEnv APPLICATION_ENV development
 
 * Parancssorból:
    
    export APP_ENV=development
 
 * Futás alatt PHP-ben:
    
    setenv('APPLICATION_ENV', 'development');
    getenv('APPLICATION_ENV');
    
Így adott esetben könnyedén megváltoztathatom az alkalmazás beállításait.

A környezet teszi lehetővé, hogy eltérő beállításokat alkalmazzunk bizonyos helyezetekben, hiszen egy fejlesztői és éles rendszer teljesen más beállításokat követel meg. A Railszes fejlesztőknek mindez bizonyára ismerősen hangzik.

Szerencsére a Zend keretrendszer konfigurációs olvasója (Zend_Config) elég szabadságot biztosít, és lehetővé tesz olyan alapvető dolgokat, mint a beállítások egymásból származtatása, felülbírálása. Én személy szerint azt a konvenciót követem, hogy minden alapbeállítást egy default címkével látok el, amelyet a további környezetek kiterjesztenek, így a szükséges beállítások egyszerűen felüldefiniálhatóak.

Környezetet - a PHP ini formátumú sémáiban megszokott módon - a _[]_ jelek között hozhatunk létre, a leszármaztatást a _:_ jellel adhatjuk meg. Az alábbi példában az production(éles) környezet mindenben a default beállítasait használja, kivéve, hogy a regisztrációkról szóló értesítéseket egy másik címre irányítom át.

[default]
email.registration.email_to = csiszar.ati@gmail.com

[production : default]
email.registration.email_to = administrator@example.com

## Bootstrap osztály és a Bootstrap Resource-ok

A Zend_Application az inicializáláskor a konfigurációban megadott Bootstrap osztályhoz fordul, amely futtat minden _init prefixszel kezdődő metódust. A metódusok a Zend terminológiájában erőforrások - Resource-szok lesznek.

Például az _initView metódus a nézetekhez tartozó Resource-szot definiálhatja, amely elvégzi bizonyos paraméterek beállítását:

    # application/Bootstrap.php
    public function _initView()
    {
      $viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
      $viewRenderer->initView();
      $viewRenderer->view->doctype('XHTML1_TRANSITIONAL');
    }

Viszont hasznosabb, ha ezeket az erőforrásokat külön osztályként, a Zend_Application_Resource_ResourceAbstract absztrakt osztály megvalósításaként írjuk meg. A bootstrappelés ezzel modulárisabbá tehető: a gyakran használt erőforrások könnyedén átvihetőek lesznek egyik alkalmazásból a másikba. 

A bootstrap során alap építőelemeit a Zend keretrendszer maga is ilyen Resourcekon keresztül hívja meg: így a MVC mintához elengedhetetlen FrontController, View, Router stb. elemekre is, mint erőforrások hivatkozhatunk.

A Resourceok definiálásának/használatának van egy jótékony tulajdonsága is: a konfigurációs állományból könnyedén konfigurálhatóvá válnak. Az alábbi példában például egyszerűen meg tudom adni az MVC mintában elengedhetetlen controllerek elérését:

    resources.frontController.controllerDirectory = APPLICATION_PATH "/controllers"
    
Ha mindezzel megvagyunk következhet az MVC M része, azaz a modellek kezelése, amelyre én a Doctrine ORM-t használtam fel.
