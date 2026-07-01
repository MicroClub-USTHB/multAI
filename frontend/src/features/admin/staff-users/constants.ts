import type { StaffRole } from './types'

export const STAFF_ROLE_OPTIONS: StaffRole[] = ['admin', 'multi_team_lead', 'multi']

export const STAFF_ROLE_LABELS: Record<StaffRole, string> = {
	admin: 'Admin',
	multi_team_lead: 'Multi Team Lead',
	multi: 'Multi',
}

export const STAFF_ROLE_BADGE_CLASSES: Record<StaffRole, string> = {
	admin: 'border-sky-500/80 text-sky-400',
	multi_team_lead: 'border-violet-500/80 text-violet-400',
	multi: 'border-emerald-500/80 text-emerald-400',
}
