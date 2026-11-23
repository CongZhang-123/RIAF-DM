#!/bin/bash
set -euo pipefail
#
# RIAF-SED 一键运行脚本
# 
# 功能:
#   1. 复制数据文件 (*omi*.dat)
#   2. 复制参数文件 (in.dat)
#   3. 运行动力学计算
#   4. 运行光谱计算
#   5. 生成图片
#
START_TIME=$(date +%s)
# 路径配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RIAF_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PARAM_FILE="${1:-${PARAM_FILE:-${RIAF_ROOT}/examples/largeR_DM.dat}}"
if [[ "$PARAM_FILE" != /* ]]; then
    PARAM_FILE="$(pwd)/$PARAM_FILE"
fi

cd "$SCRIPT_DIR"
echo "工作目录: $SCRIPT_DIR"
echo ""

# ============================================================
# Step 1: 复制数据文件
# ============================================================
echo "Step 1: 复制数据文件..."
cp "${RIAF_ROOT}/fortran/aomi-1.dat" .
cp "${RIAF_ROOT}/fortran/aomi-2.dat" .
cp "${RIAF_ROOT}/fortran/aomi-3.dat" .
cp "${RIAF_ROOT}/fortran/aomi2-1.dat" .
cp "${RIAF_ROOT}/fortran/aomi2-2.dat" .
cp "${RIAF_ROOT}/fortran/aomi2-3.dat" .
cp "${RIAF_ROOT}/fortran/romi-1.dat" .
cp "${RIAF_ROOT}/fortran/romi-2.dat" .
cp "${RIAF_ROOT}/fortran/romi-3.dat" .
echo "Done."
echo ""

# ============================================================
# Step 2: 复制参数文件
# ============================================================
echo "Step 2: 复制参数文件..."
if [ ! -f "$PARAM_FILE" ]; then
    echo "参数文件不存在: $PARAM_FILE" >&2
    exit 2
fi
cp "$PARAM_FILE" in.dat
echo "参数文件: $PARAM_FILE"
#cp "${RIAF_ROOT}/param_sweep/largeR.dat" in.dat

echo "Done."
echo ""

# ============================================================
# Step 3: 运行动力学计算
# ============================================================
echo "Step 3: 运行动力学计算 (dyn.pl)..."
perl "${RIAF_ROOT}/perl/dyn.pl"
echo "Done."
echo ""

# ============================================================
# Step 4: 运行光谱计算
# ============================================================
echo "Step 4: 运行光谱计算 (spectrum.pl)..."
perl "${RIAF_ROOT}/perl/spectrum.pl"
echo "Done."
echo ""



echo "=========================================="
echo "运行完成!"
echo "=========================================="
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo "总耗时: ${ELAPSED} 秒"
