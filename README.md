# Projekt 4: Multi-mode counter
* Autors: Nicholas Jarzabek, Vaclav Javurek, David Kevely

# O Projektu
- projekt na základě přepínačů, zobrazuje na displeji hodnoty/text dle vybraného módu.
- debounce umožňuje spolehlivé stisknutí tlačítka (zákmity ignorovány)
- counter přiřazuje vybraným switchům bin. hodnoty
- bin2seg přiřazuje bin. hodnotám  hodnoty, které chceme zobrazit, dle vybraného módu (1,2,3...,A,B...,F, nebo text, což pro ten mód přiřadíme více písmen)

- změna módů, tlačítkem BTNC přepínáme multiplexer mezi módem 0,1,2->0,1,2.
- mód 0 (hex) normálně zobrazujeme 0 až F
- mód 1 (dec) výst. omezen na 0 až 9
- mód 2 (text) Do displeje vchází pouze písmena, jejich "překlad" z clk_en signálu na písmena je v blocku counter v sekci "mod 2"



bin2seg
-dle módu  a vst. z clk_en určí, které části segmentovek budou zhasnuty a rozsvíceny
display driver
- přepíná mezi řády (10 vs 1)

## Blokove schema
- <img width="1687" height="533" alt="image" src="https://github.com/user-attachments/assets/8e803b31-1f7a-4ff5-af16-d0e47a046421" />

## Vstupy a vystupy
- `SW` - switch  (ovládání displeje)
- `clk` - hodinový signál  (100 Mhz)
- `BTNC` - tlačítko čítače (přepínání módů)
- `BTNR` - reset tlačítko (resetuje counter = počítáme zase od 0)
- `AN` - anoda
- `SEG` -  segmentovka (které části segmentů svítí/nesvítí)
- `LED` - ledka (svítí/nesvítí)
- `DP` - desetinná tečka (svítí/nesvítí)

## Importovane Subory
- clk_en.vhd
- counter.vhd
- debounce.vhd
- display_driver.vhd
