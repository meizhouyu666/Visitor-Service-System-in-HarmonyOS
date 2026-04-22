export const THEME_PRIMARY: string = '#007AFF'
export const THEME_PRIMARY_DARK: string = '#005FCC'
export const THEME_PRIMARY_SOFT: string = '#EAF2FF'
export const THEME_PAGE_BG: string = '#F5F7FB'
export const THEME_SURFACE: string = '#FFFFFF'
export const THEME_SURFACE_MUTED: string = '#F2F5FA'
export const THEME_TEXT_PRIMARY: string = '#0F172A'
export const THEME_TEXT_SECONDARY: string = '#475467'
export const THEME_TEXT_TERTIARY: string = '#98A2B3'
export const THEME_BORDER_SOFT: string = '#DFE5F0'
export const THEME_SUCCESS: string = '#16A34A'
export const THEME_WARNING: string = '#F59E0B'
export const THEME_DANGER: string = '#DC2626'

export const RADIUS_SM: number = 16
export const RADIUS_MD: number = 24
export const RADIUS_LG: number = 32
export const RADIUS_XL: number = 36
export const RADIUS_PILL: number = 999

export const SHADOW_CARD: ShadowOptions = {
  radius: 18,
  color: '#0B1A3A18',
  offsetX: 0,
  offsetY: 6
}

export const SHADOW_PANEL: ShadowOptions = {
  radius: 26,
  color: '#0B1A3A22',
  offsetX: 0,
  offsetY: 10
}

export interface StatusTone {
  icon: string
  color: string
  background: string
}

export function complaintStatusTone(status: string): StatusTone {
  if (status === 'SUBMITTED') {
    return { icon: '●', color: THEME_WARNING, background: '#FFF6E6' }
  }
  if (status === 'REJECTED') {
    return { icon: '●', color: THEME_DANGER, background: '#FFECEC' }
  }
  if (status === 'APPROVED') {
    return { icon: '●', color: THEME_PRIMARY, background: THEME_PRIMARY_SOFT }
  }
  if (status === 'IN_PROGRESS') {
    return { icon: '●', color: '#2563EB', background: '#E9F0FF' }
  }
  if (status === 'RESOLVED' || status === 'CLOSED') {
    return { icon: '●', color: THEME_SUCCESS, background: '#EAF8EF' }
  }
  return { icon: '●', color: THEME_TEXT_SECONDARY, background: THEME_SURFACE_MUTED }
}

export function emergencyStatusTone(status: string): StatusTone {
  if (status === 'DRAFT') {
    return { icon: '●', color: THEME_TEXT_SECONDARY, background: THEME_SURFACE_MUTED }
  }
  if (status === 'PENDING_APPROVAL') {
    return { icon: '●', color: THEME_WARNING, background: '#FFF6E6' }
  }
  if (status === 'PUBLISHED') {
    return { icon: '●', color: THEME_PRIMARY, background: THEME_PRIMARY_SOFT }
  }
  return { icon: '●', color: THEME_TEXT_SECONDARY, background: THEME_SURFACE_MUTED }
}
