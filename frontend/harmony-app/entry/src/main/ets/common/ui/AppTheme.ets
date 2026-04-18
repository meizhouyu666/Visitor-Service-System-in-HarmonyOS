export const THEME_PRIMARY: string = '#007AFF'
export const THEME_PRIMARY_SOFT: string = '#EAF3FF'
export const THEME_PAGE_BG: string = '#F5F7FB'
export const THEME_SURFACE: string = '#FFFFFF'
export const THEME_SURFACE_MUTED: string = '#F2F5FA'
export const THEME_TEXT_PRIMARY: string = '#111827'
export const THEME_TEXT_SECONDARY: string = '#6B7280'
export const THEME_TEXT_TERTIARY: string = '#98A2B3'
export const THEME_BORDER_SOFT: string = '#E5EAF2'
export const THEME_SUCCESS: string = '#12B76A'
export const THEME_WARNING: string = '#F59E0B'
export const THEME_DANGER: string = '#DC2626'

export const RADIUS_SM: number = 10
export const RADIUS_MD: number = 14
export const RADIUS_LG: number = 18
export const RADIUS_PILL: number = 999

export const SHADOW_CARD: ShadowOptions = {
  radius: 14,
  color: '#0F172A14',
  offsetX: 0,
  offsetY: 4
}

export const SHADOW_PANEL: ShadowOptions = {
  radius: 20,
  color: '#0F172A18',
  offsetX: 0,
  offsetY: 8
}

export interface StatusTone {
  icon: string
  color: string
  background: string
}

export function complaintStatusTone(status: string): StatusTone {
  if (status === 'SUBMITTED') {
    return { icon: '🕒', color: THEME_WARNING, background: '#FFF7E6' }
  }
  if (status === 'REJECTED') {
    return { icon: '⚠', color: THEME_DANGER, background: '#FFF1F1' }
  }
  if (status === 'APPROVED') {
    return { icon: '✔', color: THEME_PRIMARY, background: THEME_PRIMARY_SOFT }
  }
  if (status === 'IN_PROGRESS') {
    return { icon: '🛠', color: '#7C3AED', background: '#F3ECFF' }
  }
  if (status === 'RESOLVED') {
    return { icon: '✅', color: THEME_SUCCESS, background: '#ECFDF3' }
  }
  if (status === 'CLOSED') {
    return { icon: '✅', color: THEME_SUCCESS, background: '#ECFDF3' }
  }
  return { icon: '•', color: THEME_TEXT_SECONDARY, background: THEME_SURFACE_MUTED }
}

export function emergencyStatusTone(status: string): StatusTone {
  if (status === 'DRAFT') {
    return { icon: '📝', color: THEME_TEXT_SECONDARY, background: THEME_SURFACE_MUTED }
  }
  if (status === 'PENDING_APPROVAL') {
    return { icon: '🕒', color: THEME_WARNING, background: '#FFF7E6' }
  }
  if (status === 'PUBLISHED') {
    return { icon: '📢', color: THEME_PRIMARY, background: THEME_PRIMARY_SOFT }
  }
  return { icon: '•', color: THEME_TEXT_SECONDARY, background: THEME_SURFACE_MUTED }
}
