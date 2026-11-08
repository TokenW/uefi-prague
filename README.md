# uefi-prague

> Redmi K90 Max (prague) UEFI firmware for UniXNU
> SoC: MediaTek Dimensity 9500 (MT6993)

基于 Mu-Silicium 框架的 UEFI 固件，为红米 K90 Max 提供 UEFI 引导环境，支持 UniXNU 引导 iOS/iPadOS。

## 目录结构

```
uefi-prague/
├── BootShim/                    # BootShim 跳转代码
├── Resources/
│   ├── Configs/
│   │   └── prague.toml          # 设备配置（地址、镜像参数）
│   └── Scripts/                # 构建脚本
├── Platforms/
│   └── MediaTek/
│       ├── praguePkg/           # 设备级包
│       │   ├── prague.dsc      # DSC 描述文件
│       │   └── prague.fdf       # FDF 固件卷描述
│       └── MT6993Pkg/           # SoC 级包
│           └── MT6993Pkg.dec    # SoC 包声明
├── Silicon/
│   └── MediaTek/               # 联发科 Silicon 驱动
└── Common/                      # 公共代码
```

## 硬件配置

| 项目 | 值 |
|------|-----|
| 设备代号 | prague |
| SoC | MT6993 (Dimensity 9500) |
| CPU | 3 cluster 8 核 (A925×7 + X925×1) |
| 内存 | 12 GB LPDDR5X |
| GIC | GICv3, GICD @ 0x06800000 |
| 存储 | UFS, 控制器 @ 0x16810000 |
| 显示 | 1280×2772 DSC, DSI0 @ 0x3e730000 |
| 触摸 | Goodix GT9895, SPI6 |

## 必需 UEFI 模块

- [x] UniXNU (启动菜单)
- [x] UniXNUDxe (启动选项注册)
- [x] DarwinBoot (XNU 加载器)
- [x] UniXNURamDiskDxe (ramdisk 块设备)
- [x] DiskIoDxe (磁盘访问)
- [x] FatDxe (FAT 文件系统)
- [ ] GIC 驱动 (待实现)
- [ ] UART 串口驱动 (待实现)
- [ ] 显示 GOP 驱动 (待实现)
- [ ] UFS 存储驱动 (待实现)

## 构建

```bash
# 在 UniXNU 主仓库中
./unixnu defconfig prague_defconfig -D ../UniXNU-prague
./unixnu build firmware --uefi ../uefi-prague
```

## 刷机方案

GKI 布局，双分区方案：

```
fastboot flash boot_a unixnu-preboot-uefi.img
fastboot flash vendor_boot_a unixnu-payload.img
```

## 参考

- [UniXNU 主仓库](https://github.com/UniXNU/UniXNU)
- [dali (MT6991) 参考适配](https://github.com/localhosts-A/UniXNU-Dali)
- [Mu-Silicium](https://github.com/Mu-Silicium)
