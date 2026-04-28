# Projekt 4: Multi-mode counter
* Autors: Nicholas Jarzabek, Vaclav Javurek, David Kevely

# O Projektu
- projekt na základě přepínačů, zobrazuje na displeji hodnoty/text dle vybraného módu.
- debounce umožňuje spolehlivé stisknutí tlačítka (zákmity ignorovány)
- counter přiřazuje vybraným switchům bin. hodnoty
- bin2seg přiřazuje bin. hodnotám  hodnoty, které chceme zobrazit, dle vybraného módu (1,2,3...,A,B...,F, nebo text, což pro ten mód přiřadíme více písmen)

## Popis funkčnosti tlačidiel 
- změna módů, tlačítkem BTNR přepínáme multiplexer mezi módem 0,1,2->0,1,2, případně opačným směrem)
- sw(0) zapíná vypíná čítač.
- sw(1) mění směr změny módů
- BTNC reset čítače
- mód 0 (hex) normálně zobrazujeme 0 až F
- mód 1 (dec) výst. omezen na 0 až 9
- mód 2 (text) Do displeje vchází pouze písmena, jejich "překlad" z clk_en signálu na písmena je v blocku counter v sekci "mod 2"



- bin2seg
-dle módu  a vst. z clk_en určí, které části segmentovek budou zhasnuty a rozsvíceny
- display driver
- přepíná mezi řády (10 vs 1)

## Blokove schema
- <img width="1687" height="533" alt="image" src="https://github.com/NicholasJarzabek/Project_VHDL_MMCounter/blob/main/IMGs/schema.png" />

## Vstupy a vystupy
- `SW(0)` - zapnutí/vypnutí čítače
- `SW(1)` - přepínač směru změny módů (nahoru, dolů)
- `clk` - hodinový signál  (100 Mhz)
- `BTNC` - tlačítko čítače (reset)
- `BTNR` - mění módy směrem určeným SW(1)
- `AN` - anoda
- `SEG` -  segmentovka (které části segmentů svítí/nesvítí)
- `LED` - ledka (svítí/nesvítí)
- `DP` - desetinná tečka (svítí/nesvítí)
## Simulace
<img width="1069" height="682" alt="image" src="https://github.com/user-attachments/assets/b38098e6-5195-41a0-a62f-1be5736d86ca" />

## Importovane Subory
- clk_en.vhd
- counter.vhd
- debounce.vhd
- display_driver.vhd
