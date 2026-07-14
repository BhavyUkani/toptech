import { IsNotEmpty, IsString } from 'class-validator';

export class LoginDto {
  @IsString()
  @IsNotEmpty()
  identifier: string; // Can be username, email, or phone number

  @IsString()
  @IsNotEmpty()
  password: string;
}
