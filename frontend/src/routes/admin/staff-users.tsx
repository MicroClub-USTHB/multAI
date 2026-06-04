import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { useEffect } from 'react'

import { LoadingPage } from '@/shared/ui/loading'

export const Route = createFileRoute('/admin/staff-users')({
	component: RouteComponent,
})

function RouteComponent() {
	const navigate = useNavigate()

	useEffect(() => {
		navigate({
			to: '/admin/users',
			search: { view: 'staff' },
			replace: true,
		})
	}, [navigate])

	return <LoadingPage message='Redirecting to staff users...' />
}
