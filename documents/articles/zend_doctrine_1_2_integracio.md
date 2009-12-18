---
id: 12
author: Csiszár Attila
title: "Zend Framework: Doctrine 1.2 integrálása"
created_at: 2009-12-18
image_path: zflogo.png
---

[github]: http://github.com/csiszarattila/zendframework_base "A projekt Github oldala"
[part1]: /rubysztan/cikkek/zend_bootstrap "Zend_Framework bootstrap"
[part2]: /rubysztan/cikkek/zend_doctrine_1_2_integracio "Leírás a Zend_Framework-Doctrine integrációról"

[zend_doctrine_integration_todo]: http://framework.zend.com/wiki/display/ZFDEV/Doctrine+Integration+Todo "Doctrine Integration Todo"
[doctrine_resource_plugin]: http://framework.zend.com/wiki/display/ZFPROP/Zend_Application_Resource_Doctrine+-+Matthew+Lurz "Zend Application Resource Doctrine Proposal"

Az [előző cikkben][part1] már említettem, hogy maga a Zend keretrendszer teljesen szabd utat biztosít minden komponens tekintetében így az elengedhetetlen adatbáziskezelésre sem nyújt egy konvekciózus megoldást. _Szemben mondjuk a Railsszel, amelyben az ActiveRecordot mint defacto megoldás kapjuk._

Ekkor jön a kérdés, milyen adatbáziskezelő réteget használjunk. Összetett alkalmazások esetében nem lehet kérdés, hogy ne valamilyen ORM megoldást válasszunk. A személyes tapasztalataim szerint PHP-s szinten a napjainkban elérhető legjobb ilyen megvalósítást a Doctrine nyújtja.

Lássuk tehát, hogy Én hogyam tudtam megoldani a Doctrine integrációját a [Zend alapú alkalmazásomba][github].

__Figyelem az itt leírtak csak a Doctrine 1.2-es változatával működnek.__

## Doctrine, mint Bootstrap Resource Plugin

Első lépésként világossá vált, hogy a Doctrine-t is, mint bootstrap erőforrásként hozom létre, így később minden további alkalmazásban felhasználhatom. Elsőként saját megoldás írásába kezdtem, később fedeztem fel, hogy a [Doctrine - Zend keretrendszer integrációját célzó előterjesztés][zend_doctrine_integration_todo] keretében [már készült egy teljesebb][doctrine_resource_plugin] megoldás így ezt használtam fel:

#### 1. Szerezzük be a <http://github.com/mlurz71/parables> címen található forrást, és telepítsük a library könyvtárunkba. 

Én személy szerint szeretem a külső kódjaimat "hordozhatóvá" tenni, így git sumoduleként definiáltam:
 
      # config/application.ini
      git submodule add git://github.com/mlurz71/parables.git library/Parables
      git submodule init
    
#### 2. Majd regisztráltam a __library/Parables/Application/Resource___ könyvtárt (ez tartalmazza a Bootstrap Resourceokat), mint PluginPath elérést. 
Így a Zend_Application tudni fogja, hogy innen is várhat Bootstrap erőforrásokat. Ezt a regisztrációt elvégezhetjük egyszerűen az alkalmazás konfigurációs állományán keresztül is:
    
      # config/application.ini
      pluginPaths.parables_Application_Resource = LIBRARY_PATH "/Parables/Parables/Application/Resource"

#### 3. Ezek után következhet a Doctrine osztályok automatikus betöltésének hozzáadása.
Ezt is jelentősen leegyszerűsíthetjük, ha mindössze az Zend alapértelmezett osztálybetöltőjének a namespacei közé kell felvesszük a Doctrine-t, amit ismét csak elérhetünk az alkalmazásunk konfigurációs állományán keresztül a következő sorral:
    
      # config/application.ini
      autoloaderNamespaces[] = "Doctrine"

    _Mindezt azért tehetjük meg mert a Doctrine 1.2-es verziója a szabványosabb, PEAR tipusú osztályhierarchia elnevezéseket és elrendezést használja, így a Zend osztálybetöltője minden gond nélkül meg tud bírkózni velük._

#### 4. Modell osztályok betöltése

A modell osztályok betöltése sem nehezebb feladata, viszont itt válaszút elé kerülünk: 
Használhatjuk a PEAR stílusú osztályelnevezéseket: ahol az osztályokk felveszik a könyvtár hierarchiájukat, így például a model/ könyvtárban levő osztályoknak a Model_ prefixszel kell kezdődniük. Így lesz a Product.php-ban levő Product osztályból Model_Product osztály.

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

## A Doctrine konfigurálása

Mivel a Doctrine-t szabványos Resourceként definiáltuk, a készítője pedig gondolt a konfigurációs beállítások teljes elérésére, a beállítások többségét könnyedén elérjük az alkalmazás konfigurációs állományán keresztül:

    # config/application.ini
    resources.doctrine.connections.main.dsn = "mysql://user:pass@localhost/zendfw"
    resources.doctrine.models_path          = APPLICATION_PATH "/models"

A Resource-al elérhető konfigurációs beállításokat megtaláljuk az [előterjesztés címén][doctrine_resource_plugin].

## Zárszó

  Az eddig bemutatott technikákat felhasználva elérhető a legújabb Zend keretrendszer-verzióra épülő alkalmazásváz, a Github-on[http://github.com/csiszarattila/zendframework_base] keresztül. 
  
  Az alkalmazásváz folyamatos fejlesztés alatt ál, így érdemes a figyeltek közé tenni Githubon, de akár várom a hasznos committokat is. A fejlesztéshez kapcsolódó sorozat pedig folytatódik...

## A sorozatban eddig megjelent

[Zend Framework: Zend_Application + Bootstrap + Resource][part1]

[Zend Framework: Doctrine 1.2 integrálása][part2] 