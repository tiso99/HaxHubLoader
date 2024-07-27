--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_76979 = 0;
				local b;
				while true do
					if (FlatIdent_76979 == 1) then
						return b;
					end
					if (FlatIdent_76979 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_76979 = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local FlatIdent_24A02 = 0;
			local Plc;
			while true do
				if (FlatIdent_24A02 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_7126A = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_7126A == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_7126A == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_7126A = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_2661B = 0;
				while true do
					if (FlatIdent_2661B == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local FlatIdent_475BC = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_475BC == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_475BC == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_475BC = 2;
			end
			if (FlatIdent_475BC == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_475BC = 3;
			end
			if (FlatIdent_475BC == 0) then
				Str = nil;
				if not Len then
					local FlatIdent_1076E = 0;
					while true do
						if (FlatIdent_1076E == 0) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_475BC = 1;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_7F35E = 0;
			local Type;
			local Cons;
			while true do
				if (1 == FlatIdent_7F35E) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
				if (FlatIdent_7F35E == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_7F35E = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					Inst[3] = gBits32() - (2 ^ 16);
					Inst[4] = gBits16();
				end
				if (gBit(Mask, 1, 1) == 1) then
					Inst[2] = Consts[Inst[2]];
				end
				if (gBit(Mask, 2, 2) == 1) then
					Inst[3] = Consts[Inst[3]];
				end
				if (gBit(Mask, 3, 3) == 1) then
					Inst[4] = Consts[Inst[4]];
				end
				Instrs[Idx] = Inst;
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_455BF = 0;
				while true do
					if (FlatIdent_455BF == 1) then
						if (Enum <= 29) then
							if (Enum <= 14) then
								if (Enum <= 6) then
									if (Enum <= 2) then
										if (Enum <= 0) then
											Stk[Inst[2]] = Inst[3] ~= 0;
										elseif (Enum > 1) then
											local FlatIdent_703C8 = 0;
											local A;
											while true do
												if (FlatIdent_703C8 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_703C8 = 4;
												end
												if (FlatIdent_703C8 == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_703C8 = 1;
												end
												if (FlatIdent_703C8 == 6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_703C8 = 7;
												end
												if (FlatIdent_703C8 == 4) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_703C8 = 5;
												end
												if (FlatIdent_703C8 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_703C8 = 2;
												end
												if (FlatIdent_703C8 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_703C8 = 3;
												end
												if (FlatIdent_703C8 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_703C8 = 8;
												end
												if (FlatIdent_703C8 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_703C8 = 6;
												end
												if (FlatIdent_703C8 == 8) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
											end
										else
											local A = Inst[2];
											local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											local Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
										end
									elseif (Enum <= 4) then
										if (Enum == 3) then
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum == 5) then
										local FlatIdent_981A3 = 0;
										local A;
										while true do
											if (FlatIdent_981A3 == 0) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
										end
									else
										local FlatIdent_6B983 = 0;
										local A;
										while true do
											if (FlatIdent_6B983 == 0) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
										end
									end
								elseif (Enum <= 10) then
									if (Enum <= 8) then
										if (Enum == 7) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
										else
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum == 9) then
										local FlatIdent_7909D = 0;
										while true do
											if (FlatIdent_7909D == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7909D = 2;
											end
											if (FlatIdent_7909D == 5) then
												if (Stk[Inst[2]] == Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_7909D == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7909D = 5;
											end
											if (FlatIdent_7909D == 0) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7909D = 1;
											end
											if (FlatIdent_7909D == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7909D = 4;
											end
											if (FlatIdent_7909D == 2) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7909D = 3;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 12) then
									if (Enum > 11) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum == 13) then
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								else
									local FlatIdent_5B4A8 = 0;
									local A;
									while true do
										if (FlatIdent_5B4A8 == 1) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_5B4A8 = 2;
										end
										if (FlatIdent_5B4A8 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B4A8 = 6;
										end
										if (FlatIdent_5B4A8 == 8) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (0 == FlatIdent_5B4A8) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_5B4A8 = 1;
										end
										if (FlatIdent_5B4A8 == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5B4A8 = 7;
										end
										if (FlatIdent_5B4A8 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5B4A8 = 3;
										end
										if (FlatIdent_5B4A8 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B4A8 = 4;
										end
										if (7 == FlatIdent_5B4A8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B4A8 = 8;
										end
										if (FlatIdent_5B4A8 == 4) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_5B4A8 = 5;
										end
									end
								end
							elseif (Enum <= 21) then
								if (Enum <= 17) then
									if (Enum <= 15) then
										local A = Inst[2];
										local Cls = {};
										for Idx = 1, #Lupvals do
											local FlatIdent_75224 = 0;
											local List;
											while true do
												if (FlatIdent_75224 == 0) then
													List = Lupvals[Idx];
													for Idz = 0, #List do
														local Upv = List[Idz];
														local NStk = Upv[1];
														local DIP = Upv[2];
														if ((NStk == Stk) and (DIP >= A)) then
															local FlatIdent_22216 = 0;
															while true do
																if (0 == FlatIdent_22216) then
																	Cls[DIP] = NStk[DIP];
																	Upv[1] = Cls;
																	break;
																end
															end
														end
													end
													break;
												end
											end
										end
									elseif (Enum == 16) then
										Stk[Inst[2]] = Inst[3];
									else
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									end
								elseif (Enum <= 19) then
									if (Enum == 18) then
										local B;
										local A;
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									else
										local NewProto = Proto[Inst[3]];
										local NewUvals;
										local Indexes = {};
										NewUvals = Setmetatable({}, {__index=function(_, Key)
											local Val = Indexes[Key];
											return Val[1][Val[2]];
										end,__newindex=function(_, Key, Value)
											local Val = Indexes[Key];
											Val[1][Val[2]] = Value;
										end});
										for Idx = 1, Inst[4] do
											local FlatIdent_DFF4 = 0;
											local Mvm;
											while true do
												if (FlatIdent_DFF4 == 0) then
													VIP = VIP + 1;
													Mvm = Instr[VIP];
													FlatIdent_DFF4 = 1;
												end
												if (FlatIdent_DFF4 == 1) then
													if (Mvm[1] == 29) then
														Indexes[Idx - 1] = {Stk,Mvm[3]};
													else
														Indexes[Idx - 1] = {Upvalues,Mvm[3]};
													end
													Lupvals[#Lupvals + 1] = Indexes;
													break;
												end
											end
										end
										Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
									end
								elseif (Enum == 20) then
									do
										return Stk[Inst[2]]();
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 25) then
								if (Enum <= 23) then
									if (Enum > 22) then
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									else
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum == 24) then
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local A = Inst[2];
									local B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
								end
							elseif (Enum <= 27) then
								if (Enum == 26) then
									local FlatIdent_1B881 = 0;
									local A;
									while true do
										if (FlatIdent_1B881 == 0) then
											A = Inst[2];
											do
												return Unpack(Stk, A, A + Inst[3]);
											end
											break;
										end
									end
								else
									Stk[Inst[2]][Inst[3]] = Inst[4];
								end
							elseif (Enum > 28) then
								Stk[Inst[2]] = Stk[Inst[3]];
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 44) then
							if (Enum <= 36) then
								if (Enum <= 32) then
									if (Enum <= 30) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									elseif (Enum > 31) then
										local FlatIdent_25A9F = 0;
										local A;
										while true do
											if (FlatIdent_25A9F == 0) then
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												break;
											end
										end
									else
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 34) then
									if (Enum == 33) then
										Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
									else
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum > 35) then
									local A = Inst[2];
									do
										return Unpack(Stk, A, Top);
									end
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 40) then
								if (Enum <= 38) then
									if (Enum > 37) then
										local FlatIdent_72421 = 0;
										local A;
										while true do
											if (FlatIdent_72421 == 0) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												break;
											end
										end
									else
										local FlatIdent_4508F = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_4508F == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_4508F = 1;
											end
											if (FlatIdent_4508F == 2) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_4508F = 3;
											end
											if (3 == FlatIdent_4508F) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_4508F = 4;
											end
											if (FlatIdent_4508F == 5) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4508F = 6;
											end
											if (7 == FlatIdent_4508F) then
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_4508F == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_4508F = 2;
											end
											if (FlatIdent_4508F == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_4508F = 5;
											end
											if (FlatIdent_4508F == 6) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4508F = 7;
											end
										end
									end
								elseif (Enum > 39) then
									local FlatIdent_21297 = 0;
									local A;
									while true do
										if (FlatIdent_21297 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A]();
											break;
										end
									end
								else
									local A;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 42) then
								if (Enum > 41) then
									do
										return;
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								end
							elseif (Enum == 43) then
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
							else
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum <= 52) then
							if (Enum <= 48) then
								if (Enum <= 46) then
									if (Enum > 45) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									else
										local FlatIdent_91608 = 0;
										while true do
											if (FlatIdent_91608 == 0) then
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												break;
											end
										end
									end
								elseif (Enum == 47) then
									if (Inst[2] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Stk[Inst[2]] = Upvalues[Inst[3]];
								end
							elseif (Enum <= 50) then
								if (Enum == 49) then
									if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum == 51) then
								do
									return Stk[Inst[2]];
								end
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 56) then
							if (Enum <= 54) then
								if (Enum > 53) then
									VIP = Inst[3];
								else
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								end
							elseif (Enum == 55) then
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 58) then
							if (Enum == 57) then
								Stk[Inst[2]]();
							else
								local FlatIdent_44265 = 0;
								local A;
								while true do
									if (FlatIdent_44265 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_44265 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_44265 = 2;
									end
									if (FlatIdent_44265 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_44265 = 1;
									end
									if (FlatIdent_44265 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_44265 = 7;
									end
									if (FlatIdent_44265 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_44265 = 3;
									end
									if (7 == FlatIdent_44265) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
										FlatIdent_44265 = 8;
									end
									if (FlatIdent_44265 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_44265 = 6;
									end
									if (FlatIdent_44265 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_44265 = 5;
									end
									if (FlatIdent_44265 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_44265 = 4;
									end
								end
							end
						elseif (Enum > 59) then
							Upvalues[Inst[3]] = Stk[Inst[2]];
						else
							local FlatIdent_2593F = 0;
							while true do
								if (FlatIdent_2593F == 0) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_2593F = 1;
								end
								if (FlatIdent_2593F == 3) then
									if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_2593F == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_2593F = 2;
								end
								if (FlatIdent_2593F == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2593F = 3;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_455BF == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_455BF = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!083O00028O00026O00F03F026O001040027O0040026O00084003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572004F3O0012103O00014O0017000100083O0026033O0012000100010004363O00120001001210000900013O0026030009000C000100020004363O000C00012O001D000A00014O0028000A000100022O001D0002000A3O0012103O00023O0004363O00120001000E2F00010005000100090004363O000500012O0017000100013O00022100015O001210000900023O0004363O000500010026033O0025000100030004363O002500012O0017000800083O00061300080001000100042O001D3O00054O001D3O00034O001D3O00064O001D3O00074O001D000900044O001D000A00034O00200009000200020006180009002200013O0004363O002200012O001D000900084O00390009000100010004363O004D00012O001D000900074O00390009000100010004363O004D00010026033O002C000100040004363O002C00012O0017000500053O00061300050002000100012O001D3O00024O0017000600063O0012103O00053O0026033O003D000100020004363O003D0001001210000900013O00260300090036000100010004363O0036000100122C000A00063O00201E000A000A000700201E0003000A00082O0017000400043O001210000900023O0026030009002F000100020004363O002F000100061300040003000100012O001D3O00023O0012103O00043O0004363O003D00010004363O002F00010026033O0002000100050004363O00020001001210000900013O00260300090046000100020004363O0046000100061300070004000100012O001D3O00033O0012103O00033O0004363O00020001000E2F00010040000100090004363O00400001000221000600054O0017000700073O001210000900023O0004363O004000010004363O000200012O000F8O002A3O00013O00063O00083O00028O00026O00F03F030A3O006C6F6164737472696E6703053O00652O726F72031F3O004661696C656420746F206C6F61642077686974656C6973742073637269707403483O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F7469736F2O392F4861784875624C6F616465722F6D61696E2F77686974656C6973742E6C756103043O0067616D6503073O00482O747047657400253O0012103O00014O0017000100033O0026033O0012000100020004363O0012000100122C000400034O001D000500024O00200004000200022O001D000300043O0006180003000E00013O0004363O000E00012O001D000400034O0014000400014O002400045O0004363O0024000100122C000400043O001210000500054O000D0004000200010004363O002400010026033O0002000100010004363O00020001001210000400013O0026030004001E000100010004363O001E0001001210000100063O001225000500073O00202O0005000500084O000700016O0005000700024O000200053O00122O000400023O00260300040015000100020004363O001500010012103O00023O0004363O000200010004363O001500010004363O000200012O002A3O00017O00383O00028O00026O00244003083O00506F736974696F6E03053O005544696D322O033O006E6577026O00F03F026O0034C003043O005465787403013O0058030A3O0054657874436F6C6F723303063O00436F6C6F723303103O004261636B67726F756E64436F6C6F7233026O002640026O001C4003163O004261636B67726F756E645472616E73706172656E6379026O00E03F030B3O00546578745772612O7065642O01026O00204003063O00506172656E7403083O00496E7374616E6365030A3O005465787442752O746F6E03043O0053697A65026O00224003093O005363722O656E47756903043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O0057616974466F724368696C6403093O00506C6179657247756903053O004672616D65026O006940026O00594003063O005375626D6974026O003440026O002A4003113O004D6F75736542752O746F6E31436C69636B03073O00436F2O6E656374026O00284003073O00476574204B6579026O001440030A3O00496E707574426567616E030C3O00496E7075744368616E676564030A3O00496E707574456E646564030A3O004765745365727669636503103O0055736572496E70757453657276696365026O00184003073O0054657874426F78030D3O00456E74657220746865204B6579026O0059C0026O0049C003093O00546578744C6162656C027O004003113O00484158485542204B65792053797374656D026O000840026O001040002D012O0012103O00014O00170001000C3O0026033O001C000100020004363O001C000100122C000D00043O002004000D000D000500122O000E00063O00122O000F00073O00122O001000013O00122O001100016O000D0011000200102O000B0003000D00302O000B0008000900122O000D000B3O00202O000D000D000500122O000E00063O00122O000F00063O00122O001000066O000D0010000200102O000B000A000D00122O000D000B3O00202O000D000D000500122O000E00063O00122O000F00013O00122O001000016O000D0010000200102O000B000C000D00124O000D3O0026033O002F0001000E0004363O002F000100122C000D000B3O002008000D000D000500122O000E00013O00122O000F00013O00122O001000016O000D0010000200102O0009000A000D00302O0009000F001000122O000D000B3O00202O000D000D000500122O000E00063O00122O000F00063O00122O001000066O000D0010000200102O0009000C000D00302O00090011001200124O00133O0026033O0048000100130004363O0048000100102E000900140002001202000D00153O00202O000D000D000500122O000E00166O000D000200024O000A000D3O00122O000D00043O00202O000D000D000500122O000E00103O00122O000F00013O00122O001000103O00122O001100016O000D0011000200102O000A0017000D00122O000D00043O00202O000D000D000500122O000E00013O00122O000F00013O00122O001000103O00122O001100016O000D0011000200102O000A0003000D00124O00183O0026033O0064000100010004363O0064000100122C000D00153O002016000D000D000500122O000E00196O000D000200024O0001000D3O00122O000D001A3O00202O000D000D001B00202O000D000D001C00202O000D000D001D00122O000F001E6O000D000F000200102O00010014000D00122O000D00153O00202O000D000D000500122O000E001F6O000D000200024O0002000D3O00122O000D00043O00202O000D000D000500122O000E00013O00122O000F00203O00122O001000013O00122O001100216O000D0011000200102O00020017000D00124O00063O0026033O0076000100180004363O0076000100301B000A0008002200100B000A0014000200122O000D00153O00202O000D000D000500122O000E00166O000D000200024O000B000D3O00122O000D00043O00202O000D000D000500122O000E00013O00122O000F00233O00122O001000013O00122O001100236O000D0011000200102O000B0017000D00124O00023O0026033O007D000100240004363O007D000100201E000D000C0025002019000D000D0026000221000F6O0005000D000F00010004363O002C2O010026033O0094000100270004363O0094000100122C000D00043O002007000D000D000500122O000E00103O00122O000F00013O00122O001000103O00122O001100016O000D0011000200102O000C0003000D00302O000C0008002800102O000C0014000200202O000D000A002500202O000D000D0026000613000F0001000100062O001D3O00094O00308O00303O00014O001D3O00014O00303O00024O00303O00034O0005000D000F00010012103O00243O0026033O00B5000100290004363O00B5000100201E000D0003002A002019000D000D0026000613000F0002000100042O001D3O00074O001D3O00024O001D3O00044O001D3O00064O0005000D000F000100201E000D0003002B002019000D000D0026000613000F0003000100012O001D3O00054O0005000D000F000100201E000D0003002C002019000D000D0026000613000F0004000100022O001D3O00044O001D3O00054O0012000D000F000100122O000D001A3O00202O000D000D002D00122O000F002E6O000D000F000200202O000D000D002B00202O000D000D0026000613000F0005000100032O001D3O00054O001D3O00044O001D3O00084O0005000D000F00010012103O002F3O0026033O00CE0001002F0004363O00CE000100122C000D00153O00200E000D000D000500122O000E00306O000D000200024O0009000D3O00122O000D00043O00202O000D000D000500122O000E00063O00122O000F00013O00122O001000103O00122O001100016O000D0011000200102O00090017000D00122O000D00043O00202O000D000D000500122O000E00013O00122O000F00013O00122O001000013O00122O001100016O000D0011000200102O00090003000D00302O00090008003100124O000E3O0026033O00E40001000D0004363O00E4000100102E000B0014000200201E000D000B0025002019000D000D0026000613000F0006000100012O001D3O00014O0027000D000F000100122O000D00153O00202O000D000D000500122O000E00166O000D000200024O000C000D3O00122O000D00043O00202O000D000D000500122O000E00103O00122O000F00013O00122O001000103O00122O001100016O000D0011000200102O000C0017000D00124O00273O0026033O00FC000100060004363O00FC000100122C000D00043O002034000D000D000500122O000E00103O00122O000F00323O00122O001000103O00122O001100336O000D0011000200102O00020003000D00122O000D000B3O00202O000D000D000500122O000E00063O00122O000F00063O00122O001000066O000D0010000200102O0002000C000D00102O00020014000100122O000D00153O00202O000D000D000500122O000E00346O000D000200024O0003000D3O00124O00353O0026033O00172O0100350004363O00172O0100122C000D00043O00200C000D000D000500122O000E00063O00122O000F00013O00122O001000013O00122O001100236O000D0011000200102O00030017000D00122O000D00043O00202O000D000D000500122O000E00013O00122O000F00013O00122O001000013O00122O001100076O000D0011000200102O00030003000D00302O00030008003600122O000D000B3O00202O000D000D000500122O000E00063O00122O000F00063O00122O001000066O000D0010000200102O0003000A000D00124O00373O000E2F003700232O013O0004363O00232O0100122C000D000B3O00203A000D000D000500122O000E00013O00122O000F00013O00122O001000016O000D0010000200102O0003000C000D00102O0003001400024O000400053O00124O00383O000E2F0038000200013O0004363O000200012O0017000600083O00061300080007000100032O001D3O00064O001D3O00024O001D3O00073O0012103O00293O0004363O000200012O002A3O00013O00083O00023O00030C3O00736574636C6970626F61726403233O005061737465206865726520796F7572206C696E6B20746F2067657420746865206B657900043O00122C3O00013O001210000100024O000D3O000200012O002A3O00017O00043O00028O0003043O005465787403043O004E616D6503073O0044657374726F7900233O0012103O00014O0017000100013O0026033O0002000100010004363O000200012O003000025O0020230001000200024O000200016O000300023O00202O0003000300034O000400016O00020004000200062O0002001E00013O0004363O001E0001001210000200014O0017000300033O0026030002000F000100010004363O000F0001001210000300013O00260300030012000100010004363O001200012O0030000400033O0020370004000400044O0004000200014O000400046O00040001000100044O002200010004363O001200010004363O002200010004363O000F00010004363O002200012O0030000200054O00390002000100010004363O002200010004363O000200012O002A3O00017O00093O00030D3O0055736572496E7075745479706503043O00456E756D030C3O004D6F75736542752O746F6E3103053O00546F756368028O00026O00F03F03083O00506F736974696F6E03073O004368616E67656403073O00436F2O6E65637401223O00201500013O000100122O000200023O00202O00020002000100202O00020002000300062O0001000C000100020004363O000C000100201E00013O000100122C000200023O00201E00020002000100201E00020002000400063800010021000100020004363O00210001001210000100053O00260300010019000100060004363O001900012O0030000200013O00201E0002000200072O003C00025O00201E00023O000800201900020002000900061300043O000100022O001D8O00303O00024O00050002000400010004363O002100010026030001000D000100050004363O000D00014O000200014O0032000200023O00202O00023O00074O000200033O00122O000100063O00044O000D00012O002A3O00013O00013O00033O00030E3O0055736572496E707574537461746503043O00456E756D2O033O00456E64000A4O00097O00206O000100122O000100023O00202O00010001000100202O00010001000300064O0009000100010004363O000900019O002O003C3O00014O002A3O00017O00043O00030D3O0055736572496E7075745479706503043O00456E756D030D3O004D6F7573654D6F76656D656E7403053O00546F756368010E3O00201500013O000100122O000200023O00202O00020002000100202O00020002000300062O0001000C000100020004363O000C000100201E00013O000100122C000200023O00201E00020002000100201E0002000200040006380001000D000100020004363O000D00012O003C8O002A3O00017O00053O00030D3O0055736572496E7075745479706503043O00456E756D030C3O004D6F75736542752O746F6E3103053O00546F756368028O00011C3O00201500013O000100122O000200023O00202O00020002000100202O00020002000300062O0001000C000100020004363O000C000100201E00013O000100122C000200023O00201E00020002000100201E0002000200040006380001001B000100020004363O001B0001001210000100054O0017000200023O0026030001000E000100050004363O000E0001001210000200053O00260300020011000100050004363O001100014O00036O003C00036O0017000300034O003C000300013O0004363O001B00010004363O001100010004363O001B00010004363O000E00012O002A3O00019O002O00010A4O003000015O0006383O0009000100010004363O000900012O0030000100013O0006180001000900013O0004363O000900012O0030000100024O001D00026O000D0001000200012O002A3O00017O00013O0003073O0044657374726F7900044O00307O0020195O00012O000D3O000200012O002A3O00017O00083O00028O0003083O00506F736974696F6E03053O005544696D322O033O006E657703013O005803053O005363616C6503063O004F2O6673657403013O0059011F3O001210000100014O0017000200023O00260300010002000100010004363O0002000100201E00033O00022O002200048O0002000300044O000300013O00122O000400033O00202O0004000400044O000500023O00202O00050005000500202O0005000500064O000600023O00202O00060006000500202O00060006000700202O0007000200054O0006000600074O000700023O00202O00070007000800202O0007000700064O000800023O00202O00080008000800202O00080008000700202O0009000200084O0008000800094O00040008000200102O00030002000400044O001E00010004363O000200012O002A3O00019O002O0002084O003000026O0035000200023O00063100020005000100010004363O000500012O002D00028O000200014O0033000200024O002A3O00017O00023O0003043O004E616D650001094O003000015O00201E00023O00012O003500010001000200260300010006000100020004363O000600012O002D00018O000100014O0033000100024O002A3O00017O00023O0003043O004B69636B030F3O004E6F742057686974656C697374656400054O00117O00206O000100122O000200028O000200016O00017O000B3O00028O0003053O007072696E7403173O0057686974656C697374656421204C6F6164696E673O2E03043O0077616974026O660240026O00F03F030E3O004C6F6164656420312O302F312O30030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403213O00682O7470733A2O2F706173746562696E2E636F6D2F7261772F505A666964696A7200193O0012103O00013O0026033O000A000100010004363O000A000100122C000100023O00120A000200036O00010002000100122O000100043O00122O000200056O00010002000100124O00063O0026033O0001000100060004363O0001000100122C000100023O00121F000200076O00010002000100122O000100083O00122O000200093O00202O00020002000A00122O0004000B6O000200046O00013O00024O00010001000100044O001800010004363O000100012O002A3O00017O00", GetFEnv(), ...);
