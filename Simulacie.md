## Simulacia 1
- Pri tejto simulacii program pri nahrani na desku mal menšie vady
![Simulácia](IMGs/simulace.png)

## Simulacia 2
- Na waveforme je viditeľný správne generovaný hodinový signál `clk` s pravidelným priebehom.
- Vstupná zbernica `SW[15:0]` sa počas simulácie mení (napr. `0000` → `0004` → `0008` → `000E` → `002C` → `AA2C`), pričom jednotlivé bity sa prepínajú podľa očakávania.
- Signály tlačidiel (`BTNC`, `BTNR`, `BTNL`, `BTNU`, `BTND`) obsahujú krátke impulzy.
- Výstupy:
  * `AN = FE` – aktívna jedna číslica displeja
  * `SEG = 01` – konštantný segmentový vzor
  * `LED = 0000` – bez zmeny počas celej simulácie
  * `DP = 1` – desatinná bodka vypnutá

![Simulácia](IMGs/simulacia2.png)

## Simulacia 3
- Na waveforme je viditeľný stabilný hodinový signál `clk` s pravidelným priebehom. Signály tlačidiel (`BTNL`, `BTNU`, `BTND`) obsahujú krátke impulzy v rôznych časových okamihoch.
- Výstupy displeja:
  - `AN = FE` – aktívna jedna číslica displeja
  - `SEG` sa dynamicky prepína (multiplexovanie segmentov), pričom jednotlivé bity sa rýchlo menia

- Výstup `LED[15:0]` zobrazuje binárnu hodnotu čítača:
  * menia sa najmä nižšie bity (`LED(0)` až `LED(4)`)
  * vyššie bity zostávajú nulové

Maximálna hodnota dosahuje len po `LED(4)`, pretože čítač počas simulácie prejde iba malý rozsah hodnôt. Vyššie bity by sa aktivovali až pri vyšších hodnotách, ktoré sa v krátkom čase simulácie nedosiahnu.

![Simulácia](IMGs/simulacia3.png)



