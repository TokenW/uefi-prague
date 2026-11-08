# MT6993 (Prague) UEFI 驱动开发参考表

> 从完整 DTS 提取的关键硬件信息，用于编写 UEFI 驱动。
> 生成日期：2026-11-08

---

## 1. 中断控制器 (GICv3)

| 项目 | 值 |
|------|-----|
| compatible | `arm,gic-v3` |
| GICD 基地址 | `0x06800000` |
| GICD 大小 | `0x00040000` (256 KB) |
| GICR 基地址 | `0x06880000` |
| GICR 大小 | `0x00200000` (2 MB) |
| #interrupt-cells | 4 |
| 中断分区 | 3 个 (对应 3 个 CPU cluster) |

### 驱动实现要点
- 使用标准 ARM GICv3 驱动
- GICR 区域包含每个 CPU 的 redistributor
- PPI（私有外设中断）按 cluster 分区

---

## 2. 串口 (UART) — 调试输出

| UART | 基地址 | 大小 | IRQ | compatible | 状态 |
|------|--------|------|-----|------------|------|
| UART0 | `0x16000000` | 4 KB | 0x145 | `mediatek,mt6577-uart` | - |
| **UART1** | `0x16010000` | 4 KB | 0x146 | `mediatek,mt6577-uart` | **okay** |
| UART2 | `0x16020000` | 4 KB | 0x147 | `mediatek,mt6577-uart` | - |
| UART3 | `0x16030000` | 4 KB | 0x148 | `mediatek,mt6985-uart` | - |

### 推荐调试串口
**UART1 (0x16010000)** — DTS 中 status="okay"，是当前启用的调试串口。

### 驱动实现要点
- 基于 MT6577 UART 寄存器布局（联发科经典 UART）
- 波特率时钟：来自 clock-controller
- 需配置 GPIO pinmux 才能输出

---

## 3. 存储 (UFS)

| 项目 | 值 |
|------|-----|
| 控制器 compatible | `mediatek,mt8183-ufshci` |
| 控制器基地址 | `0x16810000` |
| 控制器大小 | `0x00005000` (20 KB) |
| 主 IRQ | 0x14d |
| PHY compatible | `mediatek,mt8183-ufsphy` |
| PHY 基地址 | `0x16800000` |
| PHY 大小 | `0x00010000` (64 KB) |
| 第二控制器 | `0x16890000` (disabled) |
| DMA 一致性 | 是 (dma-coherent) |
| SMMU | 是 (iommus = <&smmu 0x63>) |

### 驱动实现要点
- 复用 MT8183 UFS HCI 驱动（联发科复用同一 IP）
- 需先初始化 PHY 再初始化 HCI
- 复位：unipro_rst / crypto_rst / hci_rst
- 时钟：11 个时钟源（ufs_sel, ufs_fde, unipro_sys 等）

---

## 4. 显示 (DSI)

| 项目 | 值 |
|------|-----|
| DSI 控制器 | `dsi@3e730000` |
| 基地址 | `0x3e730000` |
| 大小 | `0x00001000` (4 KB) |
| IRQ | 0x1c5 |
| compatible | `mediatek,disp1_dsi0`, `mediatek,mt6993-dsi` |
| 状态 | okay |

### 面板
| 面板 | compatible | 类型 |
|------|-----------|------|
| Panel1 (主) | `p12_42_02_0a_dsc_cmd,lcm` | DSC 命令模式 |
| Panel2 (备选) | `p12_36_0d_0b_dsc_cmd,lcm` | DSC 命令模式 |

### 物理参数
- 分辨率：1280 x 2772
- 像素格式：DSC (Display Stream Compression)
- 模式：命令模式 (command mode)

### 显示子系统
大量 disp-* 节点：
- disp-aal0/1 (自适应亮度)
- disp-c3d0-3 (色彩转换)
- disp-ccorr0-3 (颜色校正)
- disp-color0/1 (颜色引擎)
- disp-ovl0/1 (叠加层)
- disp-rsz0/1 (缩放)

### 驱动实现要点
- GOP Framebuffer 输出需要：
  1. 初始化 DSI 控制器
  2. 初始化面板（DSC 命令模式）
  3. 配置 framebuffer 地址和格式
- 背光控制：通过 GPIO 或 PMIC

---

## 5. GPU (Mali-G1 Ultra)

| 项目 | 值 |
|------|-----|
| GPUEB compatible | `mediatek,gpueb` |
| GPUEB 基地址 | `0x4b000000` |
| GPUEB 大小 | `0x000a0000` (640 KB) |
| GPUEB IRQ | 0x2de |
| GPU 频率控制器 | `gpufreq@48500000` |
| GPU 频率基地址 | `0x48500000` |
| GPU 共享内存地址 | `0xf9c80000` |
| GPU 共享内存大小 | `0x00180000` (1.5 MB) |
| GPU 固件 | `/vendor/firmware/mali_csffw.bin` |

### GPUEB 寄存器区域
- gpueb_base: 0x4b000000 (640 KB)
- gpueb_gpr_base: 0x4b09fc80 (256 B)
- gpueb_cfgreg_base: 0x4b140100 (512 B)
- gpueb_intc_base: 0x4b120000 (256 B)
- gpueb_dma_base: 0x4b130000 (512 B)
- mbox0: 0x4b09fd80 (640 B)

### 驱动实现要点
- GPUEB 是 GPU 的嵌入式控制处理器
- 通过 mailbox 与 AP 通信
- UEFI 阶段不需要完整 GPU 驱动，只需初始化时钟和电源

---

## 6. 时钟控制器

| 控制器 | 基地址 | 大小 | compatible |
|--------|--------|------|------------|
| cksys_mm | `0x10040000` | 4 KB | `mediatek,mt6993-cksys_mm` |
| mainpll2 | `0x10043000` | 256 B | `mediatek,mt6993-mainpll2_ctrl` |
| univpll2 | `0x10043100` | 256 B | `mediatek,mt6993-univpll2_ctrl` |

### 驱动实现要点
- UEFI 阶段只需初始化关键外设时钟（UART、UFS、DSI）
- 大部分时钟在 bootloader 阶段已经配置好了

---

## 7. 触摸输入

| 项目 | 值 |
|------|-----|
| 总线 | SPI6 (`spi6@161d0000`) |
| 设备节点 | `xiaomi_touch@0` |
| compatible | `xiaomi,touch-spi` |
| 芯片 | Goodix GT9895 / GT9916 系列 |
| 固件路径 | `/vendor/firmware/gt9895_*.bin` |
| 配置路径 | `/vendor/firmware/gt9895_cfg_*.bin` |
| 触摸固件名 | `goodix_firmware_prague` |
| 触摸配置名 | `goodix_cfg_group_prague` |
| 最大坐标 (原始) | max-x = 12800, max-y = 27727 |

### 驱动实现要点
- UEFI 阶段不需要完整触摸驱动
- 只需简单的按键输入（音量键、电源键）
- 触摸驱动留到 M5 阶段

---

## 8. PSCI

| 项目 | 值 |
|------|-----|
| compatible | `arm,psci-1.0` |
| 调用方式 | SMC |

---

## 9. 内存布局

| 区域 | 地址 | 大小 | 用途 |
|------|------|------|------|
| RAM 基地址 | `0x80000000` | 12 GiB | 主内存 |
| Framebuffer | reserved | - | 显示帧缓冲 |
| GPU 预留 | reserved | - | GPU 内存 |
| GPUEB 共享内存 | `0xf9c80000` | 1.5 MB | GPU 嵌入式核心 |
| ATF / BL31 | reserved | - | ARM Trusted Firmware |
| Hypervisor | reserved | - | Gunyah Hypervisor |
| TEE | reserved | - | 安全环境 |

---

## 10. Boot 分区布局 (GKI)

| 分区 | 大小 | 内容 |
|------|------|------|
| boot_a/b | 64 MB | GKI kernel only (无 ramdisk) |
| vendor_boot_a/b | 64 MB | vendor ramdisk + DTB + bootconfig |
| init_boot_a/b | 8 MB | first-stage init ramdisk |

### UniXNU 刷机方案
```
boot_a ← BootShim + UEFI 固件 (替换 kernel)
vendor_boot_a ← UniXNU payload (替换 vendor ramdisk)
init_boot_a ← 不动
```

---

## 驱动开发优先级

| 优先级 | 驱动 | 阶段 | 用途 |
|--------|------|------|------|
| P0 | GICv3 | M2 | 中断控制器基础 |
| P0 | UART1 | M2 | 调试串口输出 |
| P0 | Framebuffer / GOP | M2 | UEFI 菜单显示 |
| P1 | UFS HCI | M4 | 存储访问 |
| P1 | DSI 显示 | M5 | 完整显示输出 |
| P2 | 触摸 | M5 | 输入交互 |
| P2 | GPU | M6 | 硬件加速 |
