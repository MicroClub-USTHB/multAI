import { Link } from '@tanstack/react-router';

const Logo = () => {
  return (
    <Link
      to='/'
      className='flex items-center gap-2 self-center font-medium text-xl'
    >
      MultAi
    </Link>
  );
};

export default Logo;
