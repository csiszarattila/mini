---
id: 12
author: Csiszár Attila
title: "Zend Framework: Doctrine 1.2 integrálása"
created_at: 2009-12-06
image_path: zflogo.jpg
---

## A Doctrine 1.2 integrálása

Az előző cikkben már említettem, hogy maga a Zend keretrendszer teljesen szabd utat biztosít minden komponens tekintetében így az elengedhetetlen adatbáziskezelésre sem nyújt egy konvekciózus megoldást. _Szemben mondjuk a Railsszel, amelyben az ActiveRecordot mint defacto megoldás kapjuk._

Ekkor jön a kérdés, milyen adatbáziskezelő réteget használjunk. Komolyabb alkalmazások esetében nem merülhet fel a kérdés, hogy ne valamilyen ORM megoldást használjunk. A személyes tapasztalataim szerint PHP-s szinten a napjainkban elérhető legjobb ORM megvalósítást a Doctrine nyújtja.

Lássuk tehát, hogyan tudtam a Doctrine 1.2-es verzióját integrálni a Zend alapú alkalmazásomba.

__Hangsúlyozom, hogy az itt leírtak csak az 1.2-es változattal működnek.__

## Doctrine, mint Bootstrap Resource

Első lépésként világossá vált, hogy a Doctrine-t is bootstrap erőforrásként hozom létre, így később minden további alkalmazásban felhasználhatom. Elsőként saját megoldás írásába kezdtem, később fedeztem fel, hogy a Doctrine - Zend keretrendszer integrációját célzó előterjesztés keretében már készült egy komolyabb megoldás így ezt használtam fel:

1. Szerezzük be a http://github.com/mlurz71/parables címen található forrást, és telepítsük a library könyvtárunkba. 

Én személy szerint szeretem a külső kódjaimat "hordozhatóvá" tenni, így git sumoduleként definiáltam:
 
    # config/application.ini
    git submodule add git://github.com/mlurz71/parables.git library/Parables
    git submodule init
    
2. Majd regisztráltam a library/Parables/Application/Resource könyvtárt (ez tartalmazza a Bootstrap Resourceokat), mint PluginPath elérést, így a Zend_Application tudni fogja, hogy innen is várhat Bootstrap erőforrásokat. A regisztráció megtehetjük egyszerűen az alkalmazás konfigurációs állományán keresztül:
    
    # config/application.ini
    pluginPaths.parables_Application_Resource = LIBRARY_PATH "/Parables/Parables/Application/Resource"

3. Ezek után következhet az Doctrine osztályok automatikus betöltésének hozzáadása.
Ami megintcsak egyszerű feladat, mindössze az Zend alapértelmezett osztálybetöltőjének a namespacei közé kell felvennünk a Doctrine-t. Ezt is megtehetjük az alkalmazásunk konfigurációs állományában:
    
    # config/application.ini
    autoloaderNamespaces[] = "Doctrine"

Megtehetjük, hiszen a Doctrine 1.2-es verziója a szabványosabb, PEAR tipusú osztályhierarchia elnevezéseket használja, így a Zend osztálybetöltője minden gond nélkül megbírkózik velük.

4. Modell osztályok betöltése

A modell osztályok betöltése sem nehezebb feladata, de itt válaszút elé kerülünk: vagy használjuk a PEAR stílusú osztályelnevezéseket: itt az osztályokk felveszik a könyvtár hierarchiájukat, így például a model/ könyvtárban levő osztályoknak a Model_ prefixszel kell kezdődniük. Így lesz a Product.php-ban levő Product osztályból Model_Product osztály.

Nekem ez kicsit erőltetett és csúnya megoldásnak tűnik - kód szinten szebb a Product osztályra hivatkozni, és márcsak a korábbi alkalmazásokhoz való visszafele kompatibilitás miatt is ragaszkodom a modellek esetében a mindenféle prefix és névtér mentes elnevezésekhez.

Sajnos a Zend default osztálybetöltője inkább az előbbi megoldást favorizálja, de lehetőséget ad a névtér nélküli osztálybetöltésre is. Ehhez úgynevezett fallback autoloaderként kell definiálnunk, amelyet a legegyszerűbben a bootstrap osztályunkban tehetünk meg:

    # application/Bootstrap.php

    class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
    {
    
      protected function _initAutoload()
      {
        $autoloader = $this->getApplication()->getAutoloader(); 
        if (!$autoloader->isFallbackAutoloader()) { 
          $autoloader->setFallbackAutoloader(true); 
        } 
        return $autoloader; 
      }
    }

## Doctrine konfigurálása

Mivel a Doctrine-t szabványos Resourceként definiáltuk, a készítője pedig gondolt a konfigurációs beállítások teljes elérésére, a Doctrine beállítását könnyedén elvégezhetjük az alkalmazás konfigurációs állományán keresztül:

    # config/application.ini
    resources.doctrine.connections.main.dsn = "mysql://user:pass@localhost/zendfw"
    resources.doctrine.models_path          = APPLICATION_PATH "/models"

A Resource-al elérhető konfigurációs beállításokat megtaláljuk az előterjesztés címén http://framework.zend.com/wiki/display/ZFPROP/Zend_Application_Resource_Doctrine+-+Matthew+Lurz. 

## Zárszó
  A legújabb Zend keretrendszer-verzióra épülő alkalmazásváz, a Doctrine-os integrációval együtt elérhető a Github-on[http://github.com/csiszarattila/zendframework_base] keresztül. 
  
  Az alkalmazásváz folyamatos fejlesztés alatt ál, így érdemes a figyeltek közé tenni Githubon, de akár várom a hasznos committokat is. A fejlesztéshez kapcsolódó sorozat pedig folytatódik...