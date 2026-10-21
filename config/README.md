
请仔细阅读。*** ：snake：

# 为记忆和线程设置

规则根据不同物种的测试分为高要求、中等要求和低要求。

在“config.yaml”的这一部分，我们可以设置这些值。

### ：ear_of_rice：1. 我们测试中大麦的合适值示例（基因组大小~4.2 Gbp，重复次数的~75%）：

```
# 设定记忆和线程，以应对高要求的规则
high:
  mem_mb: 409600 # memory in MB
  t: 50 # number of threads

# 设定记忆和线程，以应对中等要求的规则
medium:
  mem_mb: 204800 # memory in MB
  t: 20 # number of threads

# 设定记忆和线程，以应对低要求的规则
low:
  mem_mb: 51200 # memory in MB
  t: 8 # number of threads
```

### ：蘑菇：2. 我们测试中 R. irregularis 合适值示例（基因组大小~146 Mbp，~37%重复序列）

```
# 设定记忆和线程，以应对高要求的规则
high:
  mem_mb: 204800 # memory in MB
  t: 50 # number of threads

# 设定记忆和线程，以应对中等要求的规则
medium:
  mem_mb: 20480 # memory in MB
  t: 20 # number of threads

# 设定记忆和线程，以应对低要求的规则
low:
  mem_mb: 10240 # memory in MB
  t: 8 # number of threads
```

### ：幼苗：2. 我们测试中 A. thaliana 合适值示例（基因组大小~135 Mbp，~30%重复序列）

```
# 设定记忆和线程，以应对高要求的规则
high:
  mem_mb: 153600 # memory in MB
  t: 50 # number of threads

# 设定记忆和线程，以应对中等要求的规则
medium:
  mem_mb: 20480 # memory in MB
  t: 20 # number of threads

# 设定记忆和线程，以应对低要求的规则
low:
  mem_mb: 10240 # memory in MB
  t: 8 # number of threads
```

### ：苹果：2. 我们测试中苹果的合适值示例（基因组大小~700 Mbp，~51%重复序列）

```
# 设定记忆和线程，以应对高要求的规则
high:
  mem_mb: 307200 # memory in MB
  t: 50 # number of threads

# 设定记忆和线程，以应对中等要求的规则
medium:
  mem_mb: 20480 # memory in MB
  t: 20 # number of threads

# 设定记忆和线程，以应对低要求的规则
low:
  mem_mb: 10240 # memory in MB
  t: 8 # number of threads
```


# Paths to reads

下面是一个示例，说明如何将路径设置为hifi and hic reads。它展示了 hifi 和 hic 分别被放在“resources/raw_hifi”和“resources/raw_hic”目录下的案例，进入了 “colora”目录本身。如果你愿意，也可以指定不同的路径，但请注意，如果你不使用“colora”本身的子目录，应使用绝对路径。

```
# Path to hifi reads
hifi_path: "resources/raw_hifi/"

# Path to hic reads
hic_path: "resources/raw_hic/"
```

# 设定KMC和genomescope2的参数

KMC 生成 k-mer 数据库，该数据库随后被 genomescope2 使用以估计基因组大小和其他统计信息。因此，KMC 的参数也会影响 genomescope2 的行为。

要估计 k-mer 大小，如果不确定，可以使用 Merqury 提供的脚本 `best_k.sh`，该脚本可在[这里](https://github.com/marbl/merqury/blob/master/best_k.sh)找到。

对于参数 `cs`，你必须注意基因组大小和重复率，因为这可能会导致错误的基因组大小估计。请参阅 [genomescope2 常见问题](https://github.com/tbenavi1/genomescope2.0?tab=readme-ov-file#frequently-asked-questions-faq)。

参数 `-p` 用于 genomescope2 设置模型的 ploidy。请参阅 [genomescope2 仓库](https://github.com/tbenavi1/genomescope2.0) 以获取更多详细信息。

参数 `-l` 用于 genomescope2 设置估计的 1n 峰的覆盖度。请参阅 [genomescope2 仓库](https://github.com/tbenavi1/genomescope2.0) 以获取更多详细信息。

### ：大麦：1. 我们测试中大麦的合适参数示例（基因组大小~4.2 Gbp，75%重复序列）：

```
# 设定KMC的参数
kmc:
  k: 21 # kmer size, it will be the same used for genomescope2
  ci: 1 # exclude k-mers occurring less than <value> times (default: 2)
  cs: 1000000 #maximal value of a counter (default: 255)

# 设定KMC_tools transform的参数
kmc_tools:
  cx: 1000000 # exclude k-mers occurring more of than <value> times

# 设定genomescope2的参数
genomescope2:
  optional_params:
    "-p": "1"
    "-l": ""
```

# oatk

有关如何获取感兴趣的 OATK 数据库，请参见使用部分。

注意，“c”参数（指定覆盖阈值）可以设置为核序列覆盖值的 5-10 倍。

### ：大麦：1. 我们测试中大麦的合适参数示例（基因组大小~4.2 Gbp，75%重复序列）：

```
# 设定OATK的参数
oatk:
  k: 1001 # kmer size [1001]
  c: 150 #  minimum kmer coverage [3]
  m: "resources/oatkDB/embryophyta_mito.fam" # mitochondria gene annotation HMM profile database [NULL]
  optional_params: 
    "-p": "resources/oatkDB/embryophyta_pltd.fam" # to use for species that have a plastid db
```

# fastp

Fastp 用于 hic 读取的预处理。始终会移除适配器，建议在使用 Arima Hi-C 库制备工具获取数据时使用 `config.yaml` 中的可选参数。

### 1. 使用 Arima Hi-C 库制备工具获取数据时的参数示例：

```
# 设定fastp的参数
fastp:
  optional_params:
    "--cut_front": True # to use only with Arima Hi-C library prep kit generated data
    "--cut_front_window_size": "5" # to use only with Arima Hi-C library prep kit generated data
```

### 2. 使用其他库制备工具获取数据时的参数示例：

```
# 设定fastp的参数
fastp:
  optional_params:
    "--cut_front": False # to use only with Arima Hi-C library prep kit generated data
    "--cut_front_window_size": "" # to use only with Arima Hi-C library prep kit generated data
```

# hifiasm

Hifiasm 是 colora 使用的汇编器。可以用 Colora 获得主组件或分阶段组件。你可以在`config.yaml`中分别设置`phased_assembly: False` 或`phased_assembly: True` 来选择。在分阶段组装的情况下，Hi-C 读段在组装过程中集成，经过 fastp 预处理以去除适配器（以及 Arima 库准备套件中 5' 端）。

其他参数都是可选的，你可以参考[hifiasm documentation](https://hifiasm.readthedocs.io/en/latest/index.html)来了解最适合你情况的参数。


如果你的样品也有 ONT 读数，可以考虑在组装过程中使用它们。记住，如果需要，你应该先修剪它们，然后合并成一个单一的文件夹（如果它们分成多个文件夹）。

### 1. 示例：主组件组装（hifiasm 仅使用 HiFi 读数）：

```
# 可定制的hifiasm参数
hifiasm:
  phased_assembly: False # set to true if you want to obtain a phased assembly
  optional_params:
    "-f": "" # used for small datasets
    "-l": "" # purge level. 0: no purging; 1: light; 2/3: aggressive [0 for trio; 3 for unzip]
    "--ul": "" # use this if you have also ont data you want to integrate in your assembly
```

### 2. 示例：主组件组装（hifiasm 使用 HiFi 和 ONT 读数）：

```
# 可定制的hifiasm参数
hifiasm:
  phased_assembly: False # set to true if you want to obtain a phased assembly
  optional_params:
    "-f": "" # used for small datasets
    "-l": "" # purge level. 0: no purging; 1: light; 2/3: aggressive [0 for trio; 3 for unzip]
    "--ul": "resources/raw_ont/ont_reads.fastq.gz" # use this if you have also ont data you want to integrate in your assembly
```

### 3. 示例：分阶段组件组装（hifiasm 使用 HiFi、Hi-C 和额外可选参数）：

```
# 可定制的hifiasm参数
hifiasm:
  phased_assembly: True # set to true if you want to obtain a phased assembly
  optional_params:
    "--hom-cov": "181"
    "-f": "" # used for small datasets
    "-l": "" # purge level. 0: no purging; 1: light; 2/3: aggressive [0 for trio; 3 for unzip]
    "--ul": "" # use this if you have also ont data you want to integrate in your assembly
```

### 4. 示例：分阶段组件组装（hifiasm 使用 HiFi、Hi-C 和 ONT 读数）：

```
# 可定制的hifiasm参数
hifiasm:
  phased_assembly: True # set to true if you want to obtain a phased assembly
  optional_params:
    "-f": "" # used for small datasets
    "-l": "" # purge level. 0: no purging; 1: light; 2/3: aggressive [0 for trio; 3 for unzip]
    "--ul": "resources/raw_ont/ont_reads.fastq.gz" # use this if you have also ont data you want to integrate in your assembly
```

# FCS-gx

FCS-gx 是执行组件去污的工具。不过，设置 `include_fcsgx: False`时可以跳过此规则。这个选择是因为 FCS-gx 使用的数据库只有~500GB，需要大容量内存，我们希望 colora 尽可能便携。跳过这个规则，即使是小系统也能运行 Colora。

### :ear_of_rice: 1. 示例：适合大麦的参数：

```
#如果你想跳过 fcsgx 步骤，#Set False：include_fcsgx：只有当你事先下载了数据库时，这条规则才 #inlcude 适用（建议只在高性能计算机上运行 fcsgx。它需要大约 500GB 的磁盘空间和一个大内存）

# 可定制的fcsgx参数
fcsgx:
  ncbi_tax_id: 4513
  path_to_gx_db: "resources/gxdb"
```

### :mushroom: 2. 示例：适合 R. irregularis 的参数：

```
#如果你想跳过 fcsgx 步骤，#Set False：include_fcsgx：只有当你事先下载了数据库时，这条规则才 #inlcude 适用（建议只在高性能计算机上运行 fcsgx。它需要大约 500GB 的磁盘空间和一个大内存）
include_fcsgx: True #inlcude this rule only if you have preiously downloaded the database (recommended to run fcsgx only on a HPC. It requires around 500 GB of space on your disk and a large RAM)

# 可定制的fcsgx参数
fcsgx:
  ncbi_tax_id: 588596
  path_to_gx_db: "resources/gxdb"
```

# purge_dups

Purge_dups 是一种在大多数装配流程中用于根据读深度清除装配中光层和重叠部分的工具。
本项目（2026-10-19 起）已改造为**单次 purge**：`hifiasm` 分相组装（`phased_assembly: True`）
得到的坍缩 primary（`asm.bp.p_ctg` → `asm.primary.fa`）直接跑一次 purge_dups，
下游 `downstream_mode: "primary"` 走单链 yahs/autohic。原版 colora 的 alternate 组装
purge 规则（purge_dups2，diploid 双组装链用）已删除。

- `include_purge_dups: True/False` 控制是否跑 purge_dups（异源四倍体坍缩链上可正常启用）
- `phased_assembly: True` + `downstream_mode: "primary"` 为本项目当前组合


# Arima genomics mapping pipeline

该流水线已集成在 colora 中，将其从[原始 bash 流水线](https://github.com/ArimaGenomics/mapping_pipeline)翻译成了蛇形版本。

与原始流水线相比，我们仅做了以下改动：

- 移除 PREFIX 行以及 bwa 命令中的 -p $PREFIX 选项（原始流水线第 0 步）
- 在 bwa mem 命令中添加 -M 标记（原始流水线第 1.A 和 1.B 步）
- 将流水线拆分为多个规则

此外，colora 不处理 Hi-C 读段的技术重复与生物学重复，如有需要请参考原始流水线。

Hi-C 读段的预处理由 fastp 完成（见上文）。

本流水线每次仅可处理单个样本。

若将 hifiasm 的 `phased_assembly` 设为 `True`，则两个不同单倍型的组装将并行处理。

Arima genomics mapping pipeline 唯一可自定义的参数为 mapping quality 过滤阈值（默认值为 10）。

### 1. Arima mapping pipeline 默认 mapping quality 过滤阈值示例

与原始流程相比，我们唯一所做的更改如下：

- 移除 PREFIX 行以及 bwa 命令中的 -p $PREFIX 选项（原始流程的步骤 0）
- 在 bwa mem 命令中添加 -M 标志（原始流程的步骤 1.A 和 1.B）
- 将流水线拆分为多个规则

此外，colora 不处理 Hi-C 读数的技术重复和生物学重复，因此您必须参考原始流程来处理这些情况。

Hi-C 读数的预处理使用 fastp 完成（见上文）。

此流程一次只能处理一个样本。

如果您为 hifiasm 设置`phased_assembly: True` ，则不同单倍型的两个组装将并行处理。

您可以为 arima genomics 比对流程自定义的唯一参数是比对质量过滤器（默认值为 10）：

```
### arima 比对流程的可自定义参数：
arima:
  MAPQ_FILTER: 10
```

# yahs

YaHS 是我们用于利用 Hi-C 读段在 contig 水平组装基础上进行支架搭建的工具。

YaHS 是我们用于使用 Hi-C 读数在 contig 级别组装上进行拼接的工具。
```
# 可定制的 yahs 参数
yahs:
  optional_params: 
    "-e": "" # 可以指定 Hi-C 实验中使用的限制性酶(s)
```

N.B. From [YaHS documentation](https://github.com/c-zhou/yahs): 

> 使用 -e 选项，您可以指定 Hi-C 实验中使用的限制性酶。例如，GATC 对应 Dovetail Hi-C Kit 使用的 DpnII 限制性酶；GATC,GANTC 和 GATC,GANTC,CTNAG,TTAA 分别对应 Arima genomics 的双酶和四酶方案。有时，指定酶可能不会显著改变支架结果，甚至可能使其变差，特别是当组装的基础质量不佳时，例如由噪声较大的长读段构建的组装。

# Quast

Quast 用于在整个工作流程中对组装结果进行质量检查。它会处理：

- 由 hifiasm 产生的 contig 级别组装（可能为单倍型或主组装）
- 由 fcs-gx 产生的去污染 contig 级别组装（如果启用了该步骤）
- 由 purge_dups 产生的已清除冗余的 contig 级别主组装（如果启用了该步骤）
- 由 yahs 产生的 scaffold 级别组装

你可以选择性地提供研究物种的参考基因组，以便与组装结果进行比较。

所有可自定义的 quast 参数均为可选，你可以参考 [quast 文档](https://quast.sourceforge.net/docs/manual.html) 了解哪些参数适合你的情况。

### 1. 无参考基因组时运行 quast 的示例

此时只需将所有可选参数留空即可：
```
# 可定制的 quast 参数
quast:
  optional_params: 
    "--fragmented": ""
    "--large": ""
```

### 2. 有参考基因组时运行 quast 的示例

在这种情况下，你必须先下载你的参考基因组（以及 GFF，如果需要），并使用 `-r` 标志指定路径（`-g` 用于 GFF）：
```
# 可定制的 quast 参数
quast:
  optional_params: 
    "--fragmented": ""
    "--large": ""
    "-r": "resources/reference_genomes/yeast/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.fa"
    "-g": "resources/reference_genomes/yeast/Saccharomyces_cerevisiae.R64-1-1.101.gff3"
```

# Busco

Busco 用于在整个工作流程中对组装结果进行质量检查。它会处理：  

- 由 hifiasm 产生的 contig 水平组装
- 由 fcs-gx 产生的去污染 contig 水平组装（如包含该步骤）
- 由 purge_dups 产生的已清除冗余的 contig 水平主组装（如包含该步骤）
- 由 yahs 产生的 scaffold 水平组装

### 1. 示例：运行 busco 检查组装质量

你必须先下载你感兴趣的 busco 行age 之前运行 colora。有关如何下载 busco 行age 的说明，请参阅[这里](https://github.com/LiaOb21/colora/tree/main?tab=readme-ov-file#snakemake-workflow-colora)。

你需要在配置文件中指定你感兴趣的 busco 行age 路径。此外，你可以设置其他可选参数。例如，如果你更喜欢使用 metaeuk 而不是 miniprot（busco 默认使用），你可以自定义 `config.yaml` 如下：

```
# 可定制的 busco 参数
busco:
  lineage: "resources/saccharomycetes_odb10" # lineage to be used for busco analysis
  optional_params: 
    "--metaeuk": True
```

如果您想使用默认参数（miniprot），可以将 `"--metaeuk": ""`。


# AutoHiC scaffold 修正 (include_autohic)

yahs 之后的 3D-DNA/AutoHiC 自动纠错：matlock 把 read-name sorted Hi-C BAM 转 .mnd，
yahs AGP 转 3D-DNA .assembly，3D-DNA visualizer 生成 .hic，再由 AutoHiC
预训练神经网络检测/修正 translocation、inversion、debris 三类 scaffold 错误。

```
include_autohic: True

autohic:
  autohic_dir: "/home/pkzhu/software/AutoHiC"        # AutoHiC 仓库 (onehic.py 所在)
  model: "/home/pkzhu/software/AutoHiC/src/models/cfgs/error_model.pth"  # 预训练模型
  visualizer: ".../3d-dna/visualize/run-assembly-visualizer.sh"          # 3D-DNA visualizer
```

产物（`results/autohic_{hap}/`）：

- `out.sorted.links.mnd` — matlock 接触矩阵
- `scaffolds.assembly` — yahs AGP 转的 3D-DNA assembly 文件
- `out_JBAT.hic` — 纠错前 Hi-C contact map（Juicebox 可视化用）
- `out_JBAT.assembly` / `adjusted.assembly` — AutoHiC 纠错后 assembly
- `error_summary.json` — 三类错误检出统计

注意：AutoHiC 之后应将 out_JBAT.hic/纠错后 assembly 导入 Juicebox 做**手动 review**
（交互步骤，流程外），确认后的 review.assembly 再重建最终染色体级 FASTA。
