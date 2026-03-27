# Лабораторна робота №4.1

## Відомості

### Тема

CubeIDE + Qemu - розвертання ПЗ

### Мета

Ознайомлення з середовищем розробки STM32CubeIDE, процесом конфігурації периферії мікроконтролера STM32F407VG та запуском скомпільованого коду в емуляторі xPack QEMU Arm.

### Обладнання та програмне забезпечення

- ОС: Ubuntu 20.04 (Virtual Machine)
- IDE: STM32CubeIDE v1.11.2
- Емулятор: xPack QEMU Arm v7.2.0-1

## Підготовка до виконання

```bash
maxim@maxim-kradozhon:~$ cd Downloads
maxim@maxim-kradozhon:~/Downloads$ chmod +x st-stm32cubeide_1.11.2_14494_20230119_0724.unsigned_amd64.sh
maxim@maxim-kradozhon:~/Downloads$ bash st-stm32cubeide_1.11.2_14494_20230119_0724.unsigned_amd64.sh
...

maxim@maxim-kradozhon:~$ mkdir -p ~/opt/xPacks/qemu-arm
maxim@maxim-kradozhon:~$ cd ~/opt/xPacks/qemu-arm
maxim@maxim-kradozhon:~/opt/xPacks/qemu-arm$ tar xvf ~/Downloads/xpack-qemu-arm-7.2.0-1-linux-x64.tar.gz
xpack-qemu-arm-7.2.0-1/
xpack-qemu-arm-7.2.0-1/bin/
xpack-qemu-arm-7.2.0-1/bin/qemu-system-aarch64
xpack-qemu-arm-7.2.0-1/bin/qemu-system-gnuarmeclipse
xpack-qemu-arm-7.2.0-1/bin/qemu-system-arm
...
maxim@maxim-kradozhon:~/opt/xPacks/qemu-arm$ chmod -R -w xpack-qemu-arm-7.2.0-1
maxim@maxim-kradozhon:~/opt/xPacks/qemu-arm$ ~/opt/xPacks/qemu-arm/xpack-qemu-arm-7.2.0-1/bin/qemu-system-gnuarmeclipse --version
xPack QEMU emulator version 2.8.0 (v2.8.0-16-xpack-legacy)
Copyright (c) 2003-2016 Fabrice Bellard and the QEMU Project developers
```

## Хід роботи

### Створення проекту

У середовищі STM32CubeIDE створено новий проєкт для мікроконтролера **STM32F407VG**. Проєкту присвоєно назву `gl_starterkit_project`.

![alt text](<public/Screenshot from 2026-03-23 10-51-18.png>)

### Конфігурація периферії та тактування

У вікні Device Configuration Tool (.ioc) виконано наступні налаштування:

1.  **RCC:** Джерело тактування HSE встановлено як "Crystal/Ceramic Resonator".
    ![alt text](<public/Screenshot from 2026-03-23 10-59-23.png>)

2.  **SYS:** Режим налагодження встановлено як "Serial Wire".
    ![alt text](<public/Screenshot from 2026-03-23 10-59-57.png>)
3.  **Clock Tree:** Частоту HCLK встановлено на максимум - **168 МГц**, джерело PLLCLK - від HSE (8 МГц).
    ![alt text](<public/Screenshot from 2026-03-23 11-01-48.png>)
4.  **GPIO:** Пін **PD15** (синій світлодіод) налаштовано на режим "GPIO_Output".
    ![alt text](<public/Screenshot from 2026-03-23 11-04-42.png>)

### Написання програмного коду

У файлі `main.c` до основного циклу програми додано код для перемикання стану світлодіода з затримкою 500 мс.

```c
/* USER CODE BEGIN WHILE */
while (1)
{
    HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_15);
    HAL_Delay(500);

    /* USER CODE END WHILE */
}
```

![alt text](<public/Screenshot from 2026-03-23 11-07-45.png>)

### Адаптація проекту під QEMU

Оскільки QEMU v2.8.0 має обмежену підтримку FPU, виконано наступні кроки:

1.  У властивостях проекту встановлено `Floating point unit: None` та `Floating point ABI: Software implementation`.
    ![alt text](<public/Screenshot from 2026-03-23 11-10-20.png>)
2.  У файлі `system_stm32f4xx.c` закоментовано налаштування регістра `SCB->CPACR` для вимкнення апаратної підтримки FPU.
    ![alt text](<public/Screenshot from 2026-03-23 11-11-55.png>)

### Запуск та результати

Проект успішно зібрано та запущено в емуляторі за допомогою команди:
`qemu-system-gnuarmeclipse --verbose --board STM32F4-Discovery --mcu STM32F407VG --kernel gl_starterkit_project.elf`

У вікні термінала спостерігається циклічний вивід статусів світлодіода:

- `[led:blue on]`
- `[led:blue off]`

![alt text](<public/Screenshot from 2026-03-23 11-15-36.png>)

## Висновки

В ході лабораторної роботи було створено базовий проект для мікроконтролера STM32F407VG. Програма виконує блимання синім світлодіодом (PD15). Запуск у QEMU підтвердив працездатність логіки та коректність налаштування тактування системи.
