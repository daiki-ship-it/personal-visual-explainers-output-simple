/**
 * 図解カラーの正本（SSOT）
 * 色を変えるときはこのファイルだけ編集する。
 * 編集後: bash scripts/sync-ads-theme.sh を実行し、必要なら各図解を再デプロイ。
 */
window.ADS_THEME = {
  colors: {
    ads: {
      bg: '#F3FAFC',
      surface: '#FDFEFE',
      hover: '#F4F9FA',
      border: '#D9E5E8',
      accent: '#228FA0',
      'accent-light': '#246B89',
      text: '#224F62',
      muted: '#2C596D',
      dim: '#5F6B77',
      positive: '#10B981',
      negative: '#EF4444',
      warning: '#F59E0B',
    },
  },
  fontFamily: {
    sans: [
      '"Noto Sans JP"',
      '"Hiragino Sans"',
      '"Hiragino Kaku Gothic ProN"',
      '"Yu Gothic UI"',
      '"Meiryo"',
      'sans-serif',
    ],
  },
  gradient: {
    titleFrom: '#186995',
    titleTo: '#22a5b4',
  },
  favicon: {
    stroke: '#228FA0',
    circleAlt: '#22A5B4',
    dim: '#5F6B77',
  },
};

(function applyAdsCssVars() {
  const t = window.ADS_THEME;
  const root = document.documentElement;
  root.style.setProperty('--ads-gradient-from', t.gradient.titleFrom);
  root.style.setProperty('--ads-gradient-to', t.gradient.titleTo);
  root.style.setProperty('--ads-accent-light', t.colors.ads['accent-light']);
  root.style.setProperty('--ads-dim', t.colors.ads.dim);
})();
